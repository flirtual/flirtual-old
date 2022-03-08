<div class="box">
    <h1>Likes</h1>
    <a href="/matches" class="btn btn-gradient">Matches</a>

    <style>
        .match:nth-child(3) .right {
            transform: translate(-20px, 22px);
        }
    </style>

%   likes = `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})
%                                     <-[l:LIKED]-(p:user)
%                               WHERE NOT (u)-[:LIKED]->(p) AND
%                                     NOT (u)-[:PASSED]->(p)
%                               RETURN p.username
%                               ORDER BY l.date DESC, p.displayname' | uniq}
%   if {! isempty $likes} {
%       for (profile = $likes) {
%           (displayname avatar type) = \
%               `` \n {redis graph read 'MATCH (u:user {username: '''$logged_user'''})
%                                              <-[l:LIKED]-
%                                              (p:user {username: '''$profile'''})
%                                        WITH l.type AS type
%                                        MATCH (p:user {username: '''$profile'''})
%                                              -[:AVATAR]->
%                                              (a:avatar)
%                                        WITH DISTINCT type, p.displayname AS displayname,
%                                                      a.url AS avatar ORDER BY a.order LIMIT 1
%                                        RETURN displayname, avatar, type'}
%           if {~ $type like || ~ $type date || ~ $type hookup} {
%               tooltip = 'They liked you!'
%               icon = '❤️'
%           } {
%               tooltip = 'They want to be homies!'
%               icon = '✌&#xFE0F;'
%           }
            <a class="match" href="/%($profile%)?return=/likes">
                <img data-blink-ops="scale-crop: 80x80; scale-crop-position: smart_faces_points"
                     data-blink-uuid="%($avatar%)" width="80" height="80" />
                <span>
                    %(`{redis_html $displayname}%)
                </span>
                <span class="right" aria-label="%($tooltip%)" role="tooltip" data-microtip-position="top">
                    %($icon%)
                </span>
            </a>
%       }
%   } {
        <h2>No one has liked you yet :(</h2>
        <p>But it's only a matter of time.</p>
%   }
</div>
