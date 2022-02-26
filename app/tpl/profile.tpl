%{
if {! isempty $targ} {
    profile = $targ
} {
    profile = `{echo $req_path | sed 's/\/$//; s/.*\///'}
}

(profile serious luserious monopoly lumonopoly displayname dob country ismatch passed uliked \
 luliked lastlogin new lunew open luopen conscientious luconscientious agreeable luagreeable bio \
 vrchat discord domsub ludomsub onboarding vrlfp privacy_personality privacy_socials \
 privacy_sexuality privacy_kinks nsfw luadmin admin mod verified earlysupporter banned email) = \
    `` \n {redis graph read 'MATCH (u:user)
                             WHERE toLower(u.username) = '''`{echo $profile | tr 'A-Z' 'a-z'}^'''
                             OPTIONAL MATCH (lu:user {username: '''$^logged_user'''})
                             OPTIONAL MATCH (u)-[matched:MATCHED]-(lu)
                             OPTIONAL MATCH (u)-[uliked:LIKED]->(lu)
                             OPTIONAL MATCH (lu)-[luliked:LIKED]->(u)
                             OPTIONAL MATCH (lu)-[passed:PASSED]->(u)
                             OPTIONAL MATCH (u)-[:COUNTRY]->(c:country)
                             RETURN u.username, u.serious, lu.serious, u.monopoly, lu.monopoly,
                                    u.displayname, u.dob, toLower(c.id), exists(matched),
                                    exists(passed), exists(uliked), exists(luliked), u.lastlogin,
                                    u.new, u.lunew, sign(u.openness), sign(lu.openness),
                                    sign(u.conscientiousness), sign(lu.conscientiousness),
                                    sign(u.agreeableness), sign(lu.agreeableness), u.bio, u.vrchat,
                                    u.discord, u.domsub, lu.domsub, exists(u.onboarding),
                                    exists(u.vrlfp), u.privacy_personality, u.privacy_socials,
                                    u.privacy_sexuality, u.privacy_kinks, lu.nsfw, exists(lu.admin),
                                    exists(u.admin), exists(u.mod), exists(u.verified),
                                    exists(u.earlysupporter), exists(u.banned), u.email'}

# User-provided profile data needs formatting + sanitization
for (var = displayname vrchat discord) {
    $var = `{redis_html $$var}
}
bio = `{/bin/echo -en `{echo $bio | sed 's/\\"/"/g'} | sed 's//''/g'}

# Authenticate against privacy settings
fn isvisible field {
    {~ $(privacy_$field) everyone} ||
    {~ $(privacy_$field) matches && ~ $ismatch true} ||
    {~ $profile $logged_user}
}
%}

<script src="/js/intlpolyfill.js"></script>

% # User doesn't exist, was banned/deleted, or hasn't finished filling out their profile
% if {isempty $profile || {~ $onboarding true && ~ $vrlfp false} || ~ $banned true} {
    <div class="box" style="margin-top: 0">
%       if {~ $banned true && ~ $luadmin true} {
            <h1>%($displayname%)</h1>
            <p>%($profile%) (%($email%)) has been banned.</p>
            <form action="/mod" method="POST" accept-charset="utf-8">
                <input type="hidden" name="action" value="unban">
                <input type="hidden" name="user" value="%($profile%)">
                <button type="submit" class="btn btn-gradient">Unban user</button>
            </form>
%       } {
            <h1>404</h1>
            <p>Sorry, the profile you're looking for doesn't exist!</p>
%       }
    </div>
% } {
%   # Like/matched info as applicable
    <div class="buttons_top">
%       if {!~ $profile $logged_user && !~ $ismatch true} {
%           if {~ $luliked true && !~ $req_path /} {
                <div class="notice">You liked %($displayname%).</div>
%           } {~ $passed true && !~ $req_path /} {
                <div class="notice">You passed on %($displayname%).</div>
%           } {
                <form action="/like" method="POST" accept-charset="utf-8">
                    <input type="hidden" name="return" value="%($req_path%)">
                    <input type="hidden" name="user" value="%($profile%)">
                    <input type="hidden" name="type" value="like">
                    <button type="submit" class="btn btn-gradient btn-normal" style="padding-left: 13px">❤️ Like</button>
                </form>
                <form action="/like" method="POST" accept-charset="utf-8">
                    <input type="hidden" name="return" value="%($req_path%)">
                    <input type="hidden" name="user" value="%($profile%)">
                    <input type="hidden" name="type" value="homie">
                    <button type="submit" class="btn btn-gradient btn-normal" style="padding-left: 13px">✌&#xFE0F; Homie</button>
                </form>
                <form action="/pass" method="POST" accept-charset="utf-8">
                    <input type="hidden" name="return" value="%($req_path%)">
                    <input type="hidden" name="user" value="%($profile%)">
                    <button type="submit" class="btn btn-normal">Pass</button>
                </form>
%           }
%       } {~ $profile $logged_user} {
            <a href="/settings#edit" class="btn">Edit profile</a>
%       }
    </div>

%   # Contact
%   if {~ $ismatch true} {
        <p class="center">It's a match!</p>
        <a href="#converse/chat?jid=%($profile%)@%($XMPP_HOST%)" class="btn btn-gradient" style="margin-left: 50%; transform: translateX(-50%)">Message</a><br />
%   }
%   if {isvisible socials && {! isempty $vrchat || ! isempty $discord}} {
        <div class="box contact">
%           if {isvisible socials && ! isempty $vrchat} {
                <img style="transform: translateY(4px) scale(1.3)" src="/img/vrchat.svg" width="30" height="24" />
                <strong>VRChat:</strong>
                <a href="%($^vrchat%)" target="_blank" rel="nofollow noopener">
%                   echo $^vrchat | sed 's/\/$//; s/.*\///; s/%20/ /g'
                </a><br />
%           }
%           if {isvisible socials && ! isempty $discord} {
                <img src="/img/discord.svg" width="30" height="24" />
                <strong>Discord:</strong>
                %($^discord%)<br />
%           }
        </div>
%   }

    <div class="box profile">
        <div class="pfps">
            <div class="swiper">
                <div class="swiper-wrapper">
%                   avatars = `{redis graph read 'MATCH (u:user {username: '''$profile'''})-[:AVATAR]->(a:avatar)
%                                                 RETURN a.url ORDER BY a.order LIMIT 15'}
%                   for (avatar = $avatars) {
                        <div class="swiper-slide">
                            <div class="desktop">
                                <img data-blink-ops="scale-crop: 1920x1080; scale-crop-position: smart_faces_points"
                                     data-blink-uuid="%($avatar%)" />
                            </div>
                            <div class="mobile">
                                <img data-blink-ops="scale-crop: 1920x1920; scale-crop-position: smart_faces_points"
                                     data-blink-uuid="%($avatar%)" />
                            </div>
                        </div>
%                   }
                </div>
                <div class="swiper-button-prev"></div>
                <div class="swiper-button-next"></div>
            </div>

            <div class="name">
                <h2>%($displayname%)</h2>
            </div>

            <div class="asl">
%               # Age
                <span class="tag">
                    %(`{int `{/ `{- `{yyyymmdd `{date -u | sed 's/  / 0/'}} `{echo $dob | sed 's/-//g'}} 10000}}%)
                </span>


%               # Gender
%               genders = `` \n {redis graph read 'MATCH (u:user {username: '''$profile'''})-[:GENDER]->(g:gender)
%                                                 RETURN g.name
%                                                 ORDER BY g.order' | sed 's/_/ /g'}
%               if {! isempty $genders} {
%                   for (gender = $genders) {
                        <span class="tag">%($gender%)</span>
%                   }
%               }

%               # Location
%               if {! isempty $country} {
                    <span class="tag">
                        <span class="country_name" style="margin-right: 41px">%($country%)</span>
                        <span style="position: absolute; transform: translate(-31px, -3px)">
                            <img class="country" onerror="this.style.visibility='hidden'"
                                 src='/img/flags/%($country%).svg' width="33" height="25" />
                        </span>
                    </span>
%               }

%               # Badges
%               if {~ $admin true || ~ $mod true || ~ $verified true || ~ $earlysupporter true} {
                    <span class="tag badges">
%                       if {~ $admin true} {
                            <span aria-label="Flirtual Staff" role="tooltip" data-microtip-position="top">👑</span>
%                       }
%                       if {~ $mod true} {
                            <span aria-label="Moderator" role="tooltip" data-microtip-position="top">🛡️</span>
%                       }
%                       if {~ $verified true} {
                            <span aria-label="Verified Profile" role="tooltip" data-microtip-position="top">✅</span>
%                       }
%                       if {~ $earlysupporter true} {
                            <span aria-label="Early Supporter" role="tooltip" data-microtip-position="top">💖</span>
%                       }
                    </span>
%               }

%               # Last online
%               if {! isempty $lastlogin} {
%                   since_lastlogin = `{- $dateun $lastlogin}
                    <span class="lastonline">Active
%                       if {lt $since_lastlogin 172800} {
                            today
%                       } {lt $since_lastlogin 691200} {
                            this week
%                       } {lt $since_lastlogin 2764800} {
                            this month
%                       }
                    </span>
%               }
            </div>
        </div>

%       # New user?
%       if {!~ $profile $logged_user} {
%           if {~ $new true && ~ $lunew true} {
                <p style="margin-top: 45px"><em>You're both new to VR. Explore it together!</em></p>
%           } {~ $new true} {
                <p style="margin-top: 45px"><em>%($displayname%) is new to VR. Show them around!</em></p>
%           }
%       }

%       # Bio
%       if {! isempty $bio} {
            <h2 style="margin: 45px 0 -40px">About Me</h2>
            <div class="bio">%($bio%)</div>
%       } {
            <br />
%       }

%{
        # Open to serious dating
        if {~ $^serious true} {
            echo '<div class="tags">'
            echo '<span class="tag '`^{if {~ $serious $luserious} { echo common }}^'">Open to serious dating</span>'
            echo '</div>'
        }

        # Sexuality
        sexualities = `` \n {redis graph read 'MATCH (u:user {username: '''$profile'''})-[:SEXUALITY]->(s:sexuality)
                                               RETURN s.name
                                               ORDER BY s.order' | sed 's/_/ /g'}
        if {isvisible sexuality && ! isempty $sexualities} {
            echo '<div class="tags">'
            for (sexuality = $sexualities) {
                echo '<span class="tag '`^{if {~ $profile $logged_user} { echo common }}^'">'$sexuality'</span>'
            }
            echo '</div>'
        }

        # (Non-)monogamous
        if {! isempty $monopoly} {
            echo '<div class="tags">'
            echo '<span class="tag '`^{if {~ $monopoly $lumonopoly} { echo common }}^'">'$monopoly'</span>'
            echo '</div>'
        }

        # Personality traits
        if {! {~ $open 0 && ~ $conscientious 0 && ~ $agreeable 0} && ! isempty $open} {
            echo '<div class="tags">'
            if {~ $open 1} {
                echo '<span class="tag '`^{if {~ $open $luopen} { echo common }}'">Open-minded</span>'
            } {~ $open -1} {
                echo '<span class="tag '`^{if {~ $open $luopen} { echo common }}'">Practical</span>'
            }
            if {~ $conscientious 1} {
                echo '<span class="tag '`^{if {~ $conscientious $luconscientious} { echo common }}'">Reliable</span>'
            } {~ $conscientious -1} {
                echo '<span class="tag '`^{if {~ $conscientious $luconscientious} { echo common }}'">Free-spirited</span>'
            }
            if {~ $agreeable 1} {
                echo '<span class="tag '`^{if {~ $agreeable $luagreeable} { echo common }}'">Friendly</span>'
            } {~ $agreeable -1} {
                echo '<span class="tag '`^{if {~ $agreeable $luagreeable} { echo common }}'">Straightforward</span>'
            }
            echo '</div>'
        }

        # Personal tags
        common_tags = `{redis_html `{redis graph read 'MATCH (u:user {username: '''$profile'''})
                                                             -[:TAGGED]->(i:interest)<-[:TAGGED]-
                                                             (lu:user {username: '''$logged_user'''})
                                                       RETURN i.name ORDER BY i.name'}}
        tags = `{redis_html `{redis graph read 'MATCH (u:user {username: '''$profile'''})
                                                      -[:TAGGED]->(i:interest),
                                                      (lu:user {username: '''$logged_user'''})
                                                WHERE NOT (lu)-[:TAGGED]->(i)
                                                RETURN i.name ORDER BY i.name'}}
        if {! isempty $common_tags || ! isempty $tags} {
            echo '<div class="tags">'
            if {! isempty $common_tags} {
                for (tag = $common_tags) {
                    echo '<span class="tag common">'^`^{echo $tag | sed 's/_/ /g'}^'</span>'
                }
            }
            if {! isempty $tags} {
                for (tag = $tags) {
                    echo '<span class="tag">'^`^{echo $tag | sed 's/_/ /g'}^'</span>'
                }
            }
            echo '</div>'
        }

        # Games
        common_games = `{redis_html `{redis graph read 'MATCH (u:user {username: '''$profile'''})
                                                              -[:PLAYS]->(g:game)<-[:PLAYS]-
                                                              (lu:user {username: '''$logged_user'''})
                                                        OPTIONAL MATCH (o:user)-[:PLAYS]->(g)
                                                        RETURN g.name ORDER BY count(o) DESC, g.name'}}
        games = `{redis_html `{redis graph read 'MATCH (u:user {username: '''$profile'''})
                                                       -[:PLAYS]->(g:game),
                                                       (lu:user {username: '''$logged_user'''})
                                                 WHERE NOT (lu)-[:PLAYS]->(g)
                                                 OPTIONAL MATCH (o:user)-[:PLAYS]->(g)
                                                 RETURN g.name ORDER BY count(o) DESC, g.name'}}
        if {! isempty $games || ! isempty $common_games} {
            echo '<div class="tags">'
            if {! isempty $common_games} {
                for (game = $common_games) {
                    echo '<span class="tag common">'^`^{echo $game | sed 's/_/ /g'}^'</span>'
                }
            }
            if {! isempty $games} {
                for (game = $games) {
                    echo '<span class="tag">'^`^{echo $game | sed 's/_/ /g'}^'</span>'
                }
            }
            echo '</div>'
        }

        # Dom/sub/switch
        if {~ $nsfw true && isvisible kinks && {! isempty $domsub}} {
            echo '<div class="tags">'
            if {~ $domsub $ludomsub} {
                echo '<span class="tag common">'$domsub'</span>'
            } {
                echo '<span class="tag">'$domsub'</span>'
            }
            echo '</div>'
        }

        # Kinks
        common_kinks = `{redis_html `{redis graph read 'MATCH (u:user {username: '''$profile'''})
                                                              -[:KINK]->
                                                              (k:kink)
                                                              <-[:KINK]-
                                                              (lu:user {username: '''$logged_user'''})
                                                        RETURN k.name ORDER BY k.order'}}
        kinks = `{redis_html `{redis graph read 'MATCH (u:user {username: '''$profile'''})-[:KINK]->(k:kink),
                                                       (lu:user {username: '''$logged_user'''})
                                                 WHERE NOT (lu)-[:KINK]->(k)
                                                 RETURN k.name ORDER BY k.order'}}
        if {~ $nsfw true && isvisible kinks && {! isempty $kinks || ! isempty $common_kinks}} {
            echo '<div class="tags">'
            if {! isempty $common_kinks} {
                for (kink = $common_kinks) {
                    echo '<span class="tag common">'^`^{echo $kink | sed 's/_/ /g'}^'</span>'
                }
            }
            if {! isempty $kinks} {
                for (kink = $kinks) {
                    echo '<span class="tag">'^`^{echo $kink | sed 's/_/ /g'}^'</span>'
                }
            }
            echo '</div>'
        }
%}
    </div>

%   if {!~ $profile $logged_user} {
        <div class="buttons_bottom">
%           # Unmatch button
%           if {~ $ismatch true} {
                <form action="/unmatch" method="POST" accept-charset="utf-8" style="display: inline-block; margin-right: 1em">
                    <input type="hidden" name="return" value="%($req_path%)">
                    <input type="hidden" name="user" value="%($profile%)">
                    <button type="submit" class="btn btn-normal">Unmatch</button>
                </form>
%           }

%           # Report/ban button
%           if {!~ $profile $logged_user} {
%               if {~ $luadmin true} {
                    <form action="/mod" method="POST" accept-charset="utf-8">
                        <input type="hidden" name="action" value="ban">
                        <input type="hidden" name="user" value="%($profile%)">
                        <button type="submit" class="btn btn-normal">Ban user</button>
                    </form>
%               } {
                    <a href="/report?user=%($profile%)" class="btn btn-normal">Report user</a>
%               }
%           }
        </div>
%   }
% }

<script type="text/javascript">
    window.addEventListener("load", function(event) {
        if (document.querySelector(".country_name")) {
            var country = document.querySelector(".country_name");
            country.innerHTML = new Intl.DisplayNames([], {type: 'region'}).of(country.innerHTML.toUpperCase());
        }

        if (document.querySelector(".bio") && document.querySelector(".bio").clientHeight >= 480) {
            var shadow = document.createElement("div");
            shadow.classList.add("bio_shadow");
            shadow.onclick = function() { toggleBio() };

            var button = document.createElement("button");
            button.innerHTML = "⯆";
            button.classList.add("bio_toggle");
            button.onclick = function() { toggleBio() };

            document.querySelector(".bio").parentNode.insertBefore(button, document.querySelector(".bio").nextSibling);
            document.querySelector(".bio").parentNode.insertBefore(shadow, document.querySelector(".bio").nextSibling);
        }
    }, true);

    function toggleBio() {
        var bio = document.querySelector(".bio");
        if (bio.classList.contains("expand")) {
            bio.classList.remove("expand");
            bio.nextSibling.nextSibling.innerHTML = "⯆";
        } else {
            bio.classList.add("expand");
            bio.nextSibling.nextSibling.innerHTML = "⯅";
        }
    }
</script>
