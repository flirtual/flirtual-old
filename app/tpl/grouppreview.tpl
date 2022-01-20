%{
url = $targ
(name description) = `` \n {redis graph read 'MATCH (g:group {url: '''$url'''})
                                              RETURN g.name, g.description'}

name = `{redis_html $name}
description = `{/bin/echo -en `{echo $description | sed 's/\\"/"/g'} | sed 's//''/g'}

tags_default = `` \n {redis graph read 'MATCH (g:group {url: '''$url'''})-[:TAGGED]->(t:tag)
                                        WHERE t.category <> ''custom''
                                        RETURN t.name
                                        ORDER BY t.name'}
tags_custom = `` \n {redis graph read 'MATCH (g:group {url: '''$url'''})-[:TAGGED]->(t:tag {category: ''custom''})
                                       RETURN t.name
                                       ORDER BY t.name'}

if {! isempty $tags_default} {
    for (tag = $tags_default) {
        if {logged_in &&
            ~ `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})-[:INTERESTED_IN]->(t:tag {name: '''$tag'''})
                                  WHERE t.category <> ''custom''
                                  RETURN exists(t)'} true} {
            tags_common = ($tags_common $tag)
        } {
            tags_uncommon = ($tags_uncommon $tag)
        }
    }
}
if {! isempty $tags_custom} {
    for (tag = $tags_custom) {
        if {logged_in &&
            ~ `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})-[:INTERESTED_IN]->(t:tag {name: '''$tag''', category: ''custom''})
                                  RETURN exists(t)'} true} {
            tags_common = ($tags_common $tag)
        } {
            tags_uncommon = ($tags_uncommon $tag)
        }
    }
}
%}

<div class="box">
    <h1><a href="/g/%($url%)">%($name%)</a></h1>
    <div class="bio">%($description%)</div>
    <div class="interests">
%       if {! isempty $tags_common} {
%           for (tag = $tags_common) {
                <span class="common">%(`{echo $tag | sed 's/____/+/g; s/___/\//g; s/__/-/g; s/_/ /g'}%)</span>
%           }
%       }

%       if {! isempty $tags_uncommon} {
%           for (tag = $tags_uncommon) {
                <span>%(`{echo $tag | sed 's/____/+/g; s/___/\//g; s/__/-/g; s/_/ /g'}%)</span>
%           }
%       }
    </div>
    <a href="/g/%($url%)" class="btn btn-mango">Group page</a>
</div>
