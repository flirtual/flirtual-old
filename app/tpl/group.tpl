%{
group = `{echo $req_path | sed 's/\/$//; s/.*\///'}
(name url description type invite isadmin ismember discord) = \
    `` \n {redis graph read 'MATCH (g:group)
                             WHERE toLower(g.url) = '''`{echo $group | tr 'A-Z' 'a-z'}^''' OR
                                   g.invite = '''$^group'''
                             OPTIONAL MATCH (au:user {username: '''$^logged_user'''})-[a:ADMINS]->(g)
                             OPTIONAL MATCH (mu:user {username: '''$^logged_user'''})-[m:MEMBER]->(g)
                             RETURN g.name, g.url, g.description, g.type, g.invite, exists(a),
                                    exists(m), g.discord'}

# User-provided group data needs formatting + sanitization
name = `{redis_html $name}
description = `{/bin/echo -en `{echo $description | sed 's/\\"/"/g'} | sed 's//''/g'}
%}

<a href="/g/" class="btn btn-blueraspberry">Back to groups</a><br /><br />
% # Group doesn't exist or is private
% if {isempty $url ||
%     {~ $type private && !~ $ismember true && !~ $group $invite}} {
      <div class="box" style="margin-top: 0">
          <h1>Group not found</h1>
          <p>Sorry, either the group you're looking for doesn't exist or it's private!</p>
      </div>
% } {
    <div class="box" style="margin-top: 0">
        <h1>%($name%)</h1>

%       if {logged_in && !~ $ismember true} {
            <br />
            <form action="/g/membership" method="POST" accept-charset="utf-8">
                <input type="hidden" name="group" value="%($invite%)">
                <button type="submit" name="action" value="join" class="btn btn-mango btn-normal">Join group</button>
            </form>
%       }

        <div class="bio">%($description%)</div>

%{
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

%       if {~ $ismember true && ! isempty $discord} {
            <br />
            <a href="https://discord.gg/%($discord%)" target="_blank" rel="nofollow noopener" class="btn btn-blueraspberry">Discord</a>
%       }

        <div class="interests">
            <h2>Tags</h2>
%           if {! isempty $tags_common} {
%               for (tag = $tags_common) {
                    <span class="common">%(`{echo $tag | sed 's/____/+/g; s/___/\//g; s/__/-/g; s/_/ /g'}%)</span>
%               }
%           }

%           if {! isempty $tags_uncommon} {
%               for (tag = $tags_uncommon) {
                    <span>%(`{echo $tag | sed 's/____/+/g; s/___/\//g; s/__/-/g; s/_/ /g'}%)</span>
%               }
%           }
        </div>

%       if {logged_in} {
            <h2>Members</h2>
%           admins = `{redis graph read 'MATCH (u:user)-[:ADMINS]->(g:group {url: '''$url'''}),
%                                              (lu:user {username: '''$logged_user'''})
%                                        RETURN u.username'}
%           for (admin = $admins) {
                <a href="/%($admin%)">%(`{redis_html `{redis graph read 'MATCH (u:user {username: '''$admin'''}) RETURN u.displayname'}}%)</a>
                <img src="/img/avatars/64/morestuff/13.png" style="position: absolute; height: 36px" /><br />
%           }

%           members = `{redis graph read 'MATCH (u:user)-[:MEMBER]->(g:group {url: '''$url'''}),
%                                               (lu:user {username: '''$logged_user'''})
%                                         WHERE NOT (u)-[:ADMINS]->(g)
%                                         RETURN u.username'}
%           if {! isempty $members} {
%               for (member = $members) {
                    <a href="/%($member%)">%(`{redis_html `{redis graph read 'MATCH (u:user {username: '''$member'''}) RETURN u.displayname'}}%)</a><br />
%               }
%           }
            <br style="margin-bottom: 1em" />

%           if {~ $isadmin true} {
                <table style="width: 100%">
                    <tr>
                        <td style="width: 1px; white-space: nowrap"><label for="invite">Invite link:</label></td>
%                       if {~ $type public} {
                            <td><input id="invite" type="text" readonly="" onclick="this.select(); document.execCommand('copy'); this.value = 'Copied!'; this.onclick = ''" style="width: 100%; color: #000" value="https://vrlfp.com/g/%($url%)"></td>
%                       } {
                            <td><input id="invite" type="text" readonly="" onclick="this.select(); document.execCommand('copy'); this.value = 'Copied!'; this.onclick = ''" style="width: 100%; color: #000" value="https://vrlfp.com/g/%($invite%)"></td>
%                       }
                    </tr>
                </table>
                <br style="margin-bottom: 1em" />
%           }

%           if {~ $ismember true} {
                <form action="/g/membership" method="POST" accept-charset="utf-8" style="display: inline-block; margin-right: 1em">
                    <input type="hidden" name="group" value="%($invite%)">
                    <button type="submit" name="action" value="leave" class="btn btn-blueraspberry btn-normal">Leave group</button>
                </form>
%           }
%       } {
            <br style="margin-bottom: 1em" />
%       }

        <a href="/report?group=%($url%)" class="btn btn-cherry btn-normal">Report group</a>
    </div>
% }
