fn redis cmd {
    # redis graph read/write -> redis GRAPH.[RO_]QUERY $REDISCLI_DB
    if {~ $cmd(1) graph} {
        if {~ $cmd(2) write} {
            rgmode = QUERY
        } {
            rgmode = RO_QUERY
        }
        cmd = GRAPH.$rgmode $REDISCLI_DB "$cmd(3 ...)^"
    }
    # Allow linebreaks in redis input, send to redis, and format output
    echo $cmd | tr '
' ' ' | redis-cli -h $REDISCLI_HOST -p $REDISCLI_PORT --no-raw | \
         sed -n '/^2\)/,/^3\)/p' | sed '$d' | sed 's/[0-9]+\) //g; s/^ *//; s/^"//; s/"$//; s/\(integer\) //; s/^$/\(nil\)/'
}

# Escape quotes for writing to redis
fn escape_redis {
    sed 's/"/\\"/g; s/''/'^\356^\200^\200^'/g'
}

# Format + sanitize redis output for html
fn redis_html {
    /bin/echo -en `{echo $* | sed 's/\\"/"/g; s/\\n/NEWLINE/g'} | escape_html | sed 's/NEWLINE/<br \/>/g; s//''/g'
}

# < redis:... -> redis GET
let (open = $fn-%open)
fn %open fd file cmd {
    if {~ $file redis:*} {
        redis GET `{echo $file | sed 's/^redis://'} | $cmd
    } {
        $open $fd $file $cmd
    }
}

# > redis:... -> redis SET
let (create = $fn-%create)
fn %create fd file cmd {
    if {~ $file redis:*} {
        redis SET `{echo $file | sed 's/^redis://'} `$cmd
    } {
        $create $fd $file $cmd
    }
}

# >> redis:... -> redis APPEND
let (append = $fn-%append)
fn %append fd file cmd {
    if {~ $file redis:*} {
        redis APPEND `{echo $file | sed 's/^redis://'} `$cmd
    } {
        $append $fd $file $cmd
    }
}

# cat redis:... -> redis GET
fn cat {
    if {~ $1 redis:*} {
        redis GET `{echo $* | sed 's/^redis://'}
    } {
        os cat $*
    }
}

# test -e redis:... -> redis EXISTS
fn test {
    if {~ $1 -e && ~ $2 redis:*} {
        return `{! redis EXISTS `{echo $*(2 ...) | sed 's/^redis://'}}
    } {
        os test $*
    }
}

# rm redis:... -> redis DEL
fn rm {
    if {~ $1 redis:*} {
        redis DEL `{echo $* | sed 's/^redis://'}
    } {
        os rm $*
    }
}
