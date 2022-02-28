<div class="box">
    <h1>Matches</h1>
%   matches = `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})
%                                       -[m:MATCHED]-
%                                       (p:user)
%                                 RETURN p.username
%                                 ORDER BY m.date DESC, p.displayname'}
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
%           if {{~ $utype date || ~ $utype hookup} &&
%               {~ $ptype date || ~ $ptype hookup}} {
%               tooltip = 'You both liked each other!'
%               icon = '❤️'
%           } {
%               tooltip = 'You matched as homies!'
%               icon = '✌&#xFE0F;'
%           }
            <a class="match" href="/%($profile%)">
                <img data-blink-ops="scale-crop: 80x80; scale-crop-position: smart_faces_points"
                     data-blink-uuid="%($avatar%)" width="80" height="80" />
                <span>
                    %(`{redis_html $displayname}%)
                </span>
                <span class="right" aria-label="%($tooltip%)" role="tooltip" data-microtip-position="top">
                    %($icon%)
                </span>
            </a>
            <a href="#converse/chat?jid=%($profile%)@%($XMPP_HOST%)" class="btn btn-gradient">
                <span class="desktop">
                    Message
                </span>
                <span class="mobile">
                    <img src="/img/msg.svg" alt="Message" width="42" height="42" style="margin: -12px" />
                </span>
            </a>
%       }
%   } {
        <h2>You haven't matched with anyone yet :(</h2>
        <p>Go like some profiles!</p>
        <a href="/" class="btn btn-gradient">Browse</a>
%   }
</div>
