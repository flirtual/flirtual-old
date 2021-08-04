NEWLINE = '
'

# Check if $var is unset, an empty string, or a nil/empty Redis key
fn isempty var {
    ~ $var () || ~ $var '' || ~ $^var '(nil)' || ~ $^var '(empty list or set)' || ~ $^var '(empty,list,or,set)'
}

# Check if $item is in space-delimited $list
fn in item list {
    ~ `{awk 'BEGIN { split("'$^list'", array); for (i in array) if (array[i] == "'$item'") print "true" }'} true
}

# Recursively strip string from variable
# e.g. '%0%0%0DDD', '%0D' -> ''
fn deep_strip var str {                        
    $var = `{echo $$var | sed 's/'$str'//g'}
    if {echo $$var | grep -s $str} {                          
        deep_strip $var $str
    }
}

# Reverse lines
fn tac {
    awk '{ a[i++] = $0 } END { for (j = i - 1; j >= 0;) print a[j--] }'
}

# 'Tue Aug 16 17:03:52 CDT 1977' -> 19770816
fn yyyymmdd date {
    echo $date | sed 's/....(...).(..)..............(....)/\3\1\2/; s/Jan/01/; s/Feb/02/; s/Mar/03/; s/Apr/04/; s/May/05/; s/Jun/06/; s/Jul/07/; s/Aug/08/; s/Sep/09/; s/Oct/10/; s/Nov/11/; s/Dec/12/'
}

# Arithmetic
fn + a b {
    awk 'BEGIN { printf "%f", '$a' + '$b' }' | sed 's/\.?0*$//'
}
fn - a b {
    awk 'BEGIN { printf "%f", '$a' - '$b' }' | sed 's/\.?0*$//'
}
fn x a b {
    awk 'BEGIN { printf "%f", '$a' * '$b' }' | sed 's/\.?0*$//'
}
fn / a b {
    awk 'BEGIN { printf "%f", '$a' / '$b' }' | sed 's/\.?0*$//'
}
fn % a b {
    awk 'BEGIN { printf "%f", '$a' % '$b' }' | sed 's/\.?0*$//'
}
fn int n {
    awk 'BEGIN { printf "%.0f", int('$n') }'
}
fn ++ v {
    $v = `{+ $$v 1}
}
fn -- v {
    $v = `{- $$v 1}
}

# Numeric comparisons
fn lt a b {
    ~ `{awk 'BEGIN { print ('$a' < '$b') }'} 1
}
fn le a b {
    ~ `{awk 'BEGIN { print ('$a' <= '$b') }'} 1
}
fn gt a b {
    ~ `{awk 'BEGIN { print ('$a' > '$b') }'} 1
}
fn ge a b {
    ~ `{awk 'BEGIN { print ('$a' >= '$b') }'} 1
}

# Use external command rather than shell builtin
fn os cmd args {
    $kwerc_root/../bin/$cmd $args
}

# Catch errors for display
fn try f {
    catch @ e msg {
        if {~ $e error} {
            notice = $msg
        }
    } {
        $f
    }
}

# If not logged in, redirect to /login and back
fn require_login {
    if {!logged_in} {
        post_redirect $base_url/login?redirect'='$req_path
    }
}

# http://werc.cat-v.org/docs/rc-template-lang
fn template file {
    awk '
    function pr(str) {
        if (lastc !~ "[{(]")
            gsub(/''/, "''''", str)
        printf "%s", str
    }
    function trans(c) {
        printf "%s", end

        lastc = c
        end = "\n"
        if (c == "%")
            end = ""
        else if (c == "(")
            printf "echo -n "
        else if (c ~ "[})]") {
            end = "''\n"
            printf "echo -n ''"
        }
    }

    BEGIN {
        lastc = "{"
        trans("}")
    }
    END {
        print end
    }

    /^%/ && $0 !~ /^%[{()}%]/ && lastc !~ /[({]/ {
        trans("%")
        print substr($0, 2)
        next
    }
    {
        if (lastc == "%")
            trans("}")
        n = split($0, a, "%")
        pr(a[1])
        for (i = 2; i <= n; i++) {
            c = substr(a[i], 1, 1)
            rest = substr(a[i], 2)

            if ((lastc !~ "[({]" && c ~ "[({]") ||
                (lastc == "{" && c == "}") ||
                (lastc == "(" && c == ")"))
                trans(c)
            else if (c == "%")
                pr("%")
            else
                pr("%" c)
            pr(rest)
        }
        pr("\n")
    }
    ' $file | es
}

# Figure out how to handle this file
fn setup_handlers {
    if {test -f $local_path.es} {
        try . $local_path.es
    }

    if {test -f $local_path.tpl} {
        local_file = $local_path.tpl
        handler_body = (template $local_file)
    } {test -f $local_path.html} {
        local_file = $local_path.html
        handler_body = (cat $local_file)
    } {~ $local_path *.html || ~ $local_path *.tpl || ~ $local_path *.es && test -f $local_path} {
        perm_redirect `{echo $req_path | sed 's/\.html$//; s/\.tpl$//; s/\.es$//'}
    } {test -f $local_path} {
        static_file $local_path
    } {test -f `{echo $local_path | sed 's/\/[^\/]*$//'}^.tpl} {
        local_file = `{echo $local_path | sed 's/\/[^\/]*$//'}^.tpl
        handler_body = (template $local_file)
    } {
        handler_body = (template tpl/404.tpl)
        echo 'Status: 404 Not Found'
    }
}

# Sanitization
fn escape_html {
    sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'
}

fn sanitize_partial_url {
    url = `{cat | sed 's/[^a-zA-Z0-9-~+_.?#=!&;,\/:%@$|*\''()\\x80-\\xff]//g; s/''/\&#039;/g'}

    deep_strip url '%0d'
    deep_strip url '%0a'
    deep_strip url '%0D'
    deep_strip url '%0A'

    echo $url
}
fn sanitize_url {
    url = `{sanitize_partial_url}

    if {! isempty $url && !~ $url http://* && !~ $url https://*} {
        url = http://$url
    }

    echo $url
}
