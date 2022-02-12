<div class="box">
    <h1>Matches</h1>
%   matches = `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})
%                                       -[m:MATCHED]-
%                                       (p:user)
%                                 RETURN p.username
%                                 ORDER BY m.date DESC'}
%   if {! isempty $matches} {
%       for (profile = $matches) {
%           (displayname avatar utype ptype) = \
%               `` \n {redis graph read 'MATCH (u:user {username: '''$logged_user'''})
%                                              -[ul:LIKED]->
%                                              (p:user {username: '''$profile'''})
%                                        WITH ul.type AS utype
%                                        MATCH (u:user {username: '''$logged_user'''})
%                                              <-[pl:LIKED]-
%                                              (p:user {username: '''$profile'''})
%                                        WITH utype, pl.type AS ptype
%                                        MATCH (p:user {username: '''$profile'''})
%                                              -[:AVATAR]->
%                                              (a:avatar)
%                                        WITH DISTINCT utype, ptype, p.displayname AS displayname,
%                                                      a.url AS avatar ORDER BY a.order LIMIT 1
%                                        RETURN displayname, avatar, utype, ptype'}
%           if {~ $utype date} {
%               title = 'You want to date.'
%           } {~ $utype homie} {
%               title = 'You want to be homies.'
%           } {~ $utype hookup} {
%               title = 'You want to hook up.'
%           }
%           if {!~ $utype $ptype} {
%               if {~ $ptype date} {
%                   title = $title $displayname 'wants to date.'
%               } {~ $ptype homie} {
%                   title = $title $displayname 'wants to be homies.'
%               } {~ $ptype hookup} {
%                   title = $title $displayname 'wants to hook up.'
%               }
%           }
            <a class="match" href="/%($profile%)">
                <img data-blink-ops="scale-crop: 80x80; scale-crop-position: smart_faces_points"
                     data-blink-uuid="%($avatar%)" width="80" height="80" />
                <span title="%($title%)">
                    %($displayname%)
%                   echo $utype $ptype | sed 's/date/❤️/g; s/homie/🫂/g; s/hookup/🍆/g; s/ //'
                </span>
            </a>
            <a href="#converse/chat?jid=%($profile%)@%($XMPP_HOST%)" class="btn btn-gradient">Message</a>
%       }
%   } {
        <h2>You haven't matched with anyone yet :(</h2>
        <p>Go like some profiles!</p>
        <a href="/" class="btn btn-gradient">Browse</a>
%   }
</div>
