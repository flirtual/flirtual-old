<h1>Sitemap</h1>

%{
tmpfile=/tmp/kwerc_sitemap_$pid.txt
tmpfilex=/tmp/kwerc_sitemapx_$pid.txt
saveddf=$dirfilter

MON2NUM='s/Jan/01/; s/Feb/02/; s/Mar/03/; s/Apr/04/; s/May/05/; s/Jun/06/; s/Jul/07/; s/Aug/08/; s/Sep/09/; s/Oct/10/; s/Nov/11/; s/Dec/12/;'

fn get_mdate {
    t=`{mtime $1}
    t=`{date $t(1) | sed -e $MON2NUM -e 's/  ([0-9]) / 0\1 /g'} # Make sure day of the month is two digits.
    echo $t(6)^'-'^$t(2)^'-'^$t(3)
}

fn list_dir {
    d=$1
    dirfilter=$saveddf
    if(test -f $d/_kwerc/config)
        . $d/_kwerc/config

    if(~ $#perm_redir_to 0) {
        echo '<ul class="sitemap-list">'

        for(i in `{ls -dF $d^*/ $d^*.md $d^*.html $d^*.txt >[2]/dev/null | sed $dirfilter}) {
            desc=`{get_file_title $i}
            u=`{echo $i|sed 's!'$sitedir'!!; '$dirclean's!/index$!/!; '}
            if(! ~ $#desc 0 && ! ~ $desc '')
                desc=' - '$"desc
            n=`{echo /$u|sed 's/[\-_]/ /g; s,.*/([^/]+)/?$,\1,'}
            echo '<li><a href="'$u'">'^$"n^'</a>' $"desc '</li>' 
            echo $base_url^$u >> $tmpfile
            echo '<url><loc>'$base_url^$u'</loc><lastmod>'^`{get_mdate $i}^'</lastmod></url>' >> $tmpfilex
            if(test -d $i)
                @{ list_dir $i }
        }
        echo '</ul>'
    }
}


fltr_cache list_dir $sitedir/

if(test -s $tmpfile) {
    mv $tmpfile $sitedir/sitemap.txt &
}
if not if(test -f $tmpfile)
    rm $tmpfile

if(test -s $tmpfilex) {
    {
        echo '<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'

        cat $tmpfilex
        rm $tmpfilex &
        echo '</urlset>'
    } | gzip > $sitedir/sitemap.gz &
    #} > $sitedir/sitemap.xml &
}
if not if(test -f $tmpfilex)
    rm $tmpfilex

%}
