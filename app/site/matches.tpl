% if {! isempty $success} {
      <div class="notice">%($success%) reset successfully!</div>
% }

<div class="box">
    <h1>Matches</h1>
%   if {~ $premium true} {
        <a href="/likes" class="btn btn-gradient" style="padding-right: 13px">Likes you <span aria-label="Premium" role="tooltip" data-microtip-position="top" style="font-family: Nunito, sans-serif">⭐</span></a>
%   } {
        <a href="/premium" class="btn btn-gradient" style="padding-right: 13px">Likes you <span aria-label="Premium" role="tooltip" data-microtip-position="top" style="font-family: Nunito, sans-serif">⭐</span></a>
%   }

    <style>
        .match:nth-child(4) .right {
            transform: translate(-185px, 22px);
        }
        @media only screen and (max-width: 991px) {
            .match:nth-child(4) .right {
                transform: translate(-91px, 22px)
            }
        }
    </style>

%   matches = `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})
%                                       -[m:MATCHED]-
%                                       (p:user)
%                                 WHERE NOT exists(p.banned) AND
%                                       NOT exists(p.shadowbanned) AND
%                                       NOT (u)-[:REPORTED]->(p)
%                                 RETURN p.username
%                                 ORDER BY m.date DESC, p.displayname' | uniq}
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
%           if {{~ $utype like || ~ $utype date || ~ $utype hookup} &&
%               {~ $ptype like || ~ $ptype date || ~ $ptype hookup}} {
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
        <br /><form action="" method="POST" accept-charset="utf-8" style="display: inline-block"
                    onsubmit="return confirm('Are you sure you want to reset all of your likes/homies? This won\'t affect your matches.')">
            <button type="submit" class="btn btn-gradient btn-normal" name="reset" value="likes">Reset likes/homies</button>
        </form>
        <form action="" method="POST" accept-charset="utf-8" style="display: inline-block"
              onsubmit="return confirm('Are you sure you want to reset all of your passes?')">
            <button type="submit" class="btn btn-gradient btn-normal" name="reset" value="passes">Reset passes</button>
        </form>
%   } {
        <h2>You haven't matched with anyone yet :(</h2>
        <p>Go like some profiles!</p>
        <a href="/" class="btn btn-gradient">Browse</a>
%   }
</div>
