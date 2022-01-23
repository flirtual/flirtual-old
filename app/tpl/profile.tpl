%{
if {! isempty $targ} {
    profile = $targ
} {
    profile = `{echo $req_path | sed 's/\/$//; s/.*\///'}
}

(profile displayname dob gender country isfriend uwaved luwaved inviter_username \
 inviter_displayname lastlogin new lunew open luopen conscientious luconscientious \
 agreeable luagreeable bio vrchat discord steam twitter instagram twitch youtube \
 reddit spotify customurl ponboarding privacy_age privacy_gender privacy_country \
 privacy_socials privacy_games privacy_interests_common \
 privacy_interests_uncommon privacy_bio privacy_language privacy_platform \
 privacy_friends privacy_invite avatar) = \
    `` \n {redis graph read 'MATCH (u:user)
                             WHERE toLower(u.username) = '''`{echo $profile | tr 'A-Z' 'a-z'}^'''
                             OPTIONAL MATCH (u)-[:COUNTRY]->(c:country)
                             OPTIONAL MATCH (lu:user {username: '''$^logged_user'''})
                             OPTIONAL MATCH (u)-[friends:FRIENDS]-(lu)
                             OPTIONAL MATCH (u)-[uwaved:WAVED]->(lu)
                             OPTIONAL MATCH (lu)-[luwaved:WAVED]->(u)
                             OPTIONAL MATCH (u)-[:REFERRED_BY]->(i:user)
                             RETURN u.username, u.displayname, u.dob, u.gender, toLower(c.id),
                                    exists(friends), exists(uwaved), exists(luwaved), i.username,
                                    i.displayname, u.lastlogin, u.new, u.lunew, sign(u.openness),
                                    sign(lu.openness), sign(u.conscientiousness),
                                    sign(lu.conscientiousness), sign(u.agreeableness),
                                    sign(lu.agreeableness), u.bio, u.vrchat, u.discord, u.steam,
                                    u.twitter, u.instagram, u.twitch, u.youtube, u.reddit, u.spotify,
                                    u.customurl, u.onboarding, u.privacy_age, u.privacy_gender,
                                    u.privacy_country, u.privacy_socials, u.privacy_games,
                                    u.privacy_interests_common, u.privacy_interests_uncommon,
                                    u.privacy_bio, u.privacy_language, u.privacy_platform,
                                    u.privacy_friends, i.privacy_invite, u.avatar'}

# User-provided profile data needs formatting + sanitization
for (var = displayname gender inviter_displayname vrchat discord steam twitter instagram twitch \
           youtube reddit spotify customurl) {
    $var = `{redis_html $$var}
}
bio = `{/bin/echo -en `{echo $bio | sed 's/\\"/"/g'} | sed 's//''/g'}

# Authenticate against privacy settings
fn isvisible field {
    {~ $(privacy_$field) public} ||
    {~ $(privacy_$field) vrlfp && logged_in} ||
    {~ $(privacy_$field) friends && ~ $isfriend true} ||
    {~ $profile $logged_user}
}
%}

<script src="/js/intlpolyfill.js"></script>

% if {! logged_in} {
    <div class="banner">
        Want a profile like this? <a href="/" target="_blank">Join VRLFP</a>, the VR social network.
	Meet cool people around the world based on common interests, personality traits, and
        friends; join and organize events across any Social VR app/game; build communities; and
        more.
    </div>
% }

% # User doesn't exist, was banned/deleted, or hasn't finished filling out their profile
% if {isempty $profile || ! isempty $ponboarding} {
    <div class="box profile" style="margin-top: 0">
        <h1>Profile not found</h1>
        <p>Sorry, the profile you're looking for doesn't exist!</p>
    </div>
% } {
    <div class="box profile" style="margin-top: 0; padding: 40px 60px 25px 60px">
%       # Basic profile info: avatar, display name, age, gender, country
        <table>
            <tr>
                <td><img class="avatar" src="/img/avatars/200/%($avatar%).png" width="200" /></td>
                <td style="padding-left: 1.5em">
                    <h1 style="margin: -0.2em 0 0.3em 0">%($displayname%)</h1>
                    <p class="info" style="margin: 0">
%                       if {! isempty $dob && isvisible age} {
                            <span>%(`{int `{/ `{- `{yyyymmdd `{date -u | sed 's/  / 0/'}} `{echo $dob | sed 's/-//g'}} 10000}}%)</span>
%                       }
%                       if {! isempty $gender && isvisible gender} {
                            <span>%($gender%)</span>
%                       }
%                       if {! isempty $country && isvisible country} {
                            <span><img class="country" onerror="this.style.visibility='hidden'"
                                       src='/img/flags/%($country%).svg' /></span>
%                       }
                    </p>
                </td>
            </tr>
        </table>

%       # Your profile? -> Edit button
%       if {~ $profile $logged_user} {
            <br /><a href="/settings#edit" class="btn btn-blueraspberry">Edit profile</a>
%       }

%       # Wave/friend/message button/info as applicable
%       if {logged_in && !~ $profile $logged_user} {
%           if {~ $isfriend true} {
                <a href="#converse/chat?jid=%($profile%)@%($XMPP_HOST%)" class="btn btn-blueraspberry" style="margin-top: 1.5em">Message</a><br />
%           } {~ $luwaved true} {
                <p style="margin-bottom: 1.4em"><strong>You waved at %($displayname%).</strong></p>
%           } {~ $uwaved true} {
                <p style="margin-bottom: 1.4em"><strong>%($displayname%) waved at you.</strong></p>
                <form action="/wave" method="POST" accept-charset="utf-8" style="margin-top: 2.5em">
                    <input type="hidden" name="return" value="%($req_path%)">
                    <input type="hidden" name="user" value="%($profile%)">
                    <button type="submit" class="btn btn-mango btn-normal">Add friend</button>
                </form>
%           } {
                <form action="/wave" method="POST" accept-charset="utf-8" style="margin-top: 2.5em">
                    <input type="hidden" name="return" value="%($req_path%)">
                    <input type="hidden" name="user" value="%($profile%)">
                    <button type="submit" class="btn btn-mango btn-normal" title="This will send a friend request.">Wave</button>
                </form>
%           }
%       }

%       # Pass button
%       if {~ $req_path /guestlist || ~ $req_path /notifications} {
            <form action="/pass" method="POST" accept-charset="utf-8">
                <input type="hidden" name="return" value="%($req_path%)">
                <input type="hidden" name="user" value="%($profile%)">
                <button type="submit" class="btn btn-blueraspberry btn-close">X</button>
            </form>
%       }

%       # Last online
%       if {!~ $profile $logged_user} {
%           since_lastlogin = `{- $dateun $lastlogin}
%           if {lt $since_lastlogin 172800} {
                <p>Last online: Today</p>
%           } {lt $since_lastlogin 691200} {
                <p>Last online: This week</p>
%           } {lt $since_lastlogin 2764800} {
                <p>Last online: This month</p>
%           }
%       }

%       # New user?
%       if {logged_in && !~ $profile $logged_user} {
%           if {~ $new true && ~ $lunew true} {
                <p><em>You're both new to VR.</em></p>
%           } {~ $new true} {
                <p><em>%($displayname%) is new to VR. Give them some tips or show them around!</em></p>
%           } {~ $lunew true} {
                <p><em>%($displayname%) is experienced at VR!</em></p>
%           }
%       }

%{
        # Friends
        friends = `` \n {redis graph read 'MATCH (u:user {username: '''$profile'''}),
                                                (lu:user {username: '''$logged_user'''}),
                                                (f:user)
                                          WHERE (u)-[:FRIENDS]-(f) AND
                                                (lu)-[:FRIENDS]-(f)
                                          RETURN f.username'}
        if {!~ $profile $logged_user && ! isempty $friends} {
            if {isvisible friends} {
                echo '<p class="ip">Mutual friends:</p>'
                for (friend = $friends) {
                    friend_displayname = `^{redis_html `{redis graph read 'MATCH (u:user {username: '''$friend'''})
                                                                           RETURN u.displayname'}}
                    echo '<a class="tag common" href="/'$friend'">'$friend_displayname'</a>'
                }
                echo '<br />'
            } {~ $privacy_friends friends} {
	        if {gt $#friends 1} {
                    echo '<p style="margin-top: 2em">'$#friends' mutual friends</p>'
		} {
                    echo '<p style="margin-top: 2em">'$#friends' mutual friend</p>'
		}
            }
        }

        # Groups
        groups = `` \n {redis graph read 'MATCH (u:user {username: '''$profile'''}),
                                               (lu:user {username: '''$logged_user'''}),
                                               (g:group)
                                         WHERE (u)-[:MEMBER]->(g) AND
                                               (lu)-[:MEMBER]->(g)
                                         RETURN g.url'}
        if {!~ $profile $logged_user && ! isempty $groups} {
            echo '<p class="ip">Mutual groups:</p>'
            for (group = $groups) {
                group_name = `^{redis_html `{redis graph read 'MATCH (g:group {url: '''$group'''})
                                                               RETURN g.name'}}
                echo '<a class="tag common" href="/g/'$group'">'$group_name'</a>'
            }
            echo '<br />'
        }

        # Personality traits
        if {logged_in && !~ $profile $logged_user &&
            {~ $open $luopen || ~ $conscientious $luconscientious || ~ $agreeable $luagreeable}} {
            echo '<p class="ip">Shared traits:</p>'
            if {~ $open $luopen} {
                if {~ $open 1} {
                    echo '<span class="tag common">open-minded</span>'
                } {
                    echo '<span class="tag common">practical</span>'
                }
            }
            if {~ $conscientious $luconscientious} {
                if {~ $conscientious 1} {
                    echo -n '<span class="tag common">reliable</span>'
                } {
                    echo -n '<span class="tag common">free-spirited</span>'
                }
            }
            if {~ $agreeable $luagreeable} {
                if {~ $agreeable 1} {
                    echo -n '<span class="tag common">friendly</span>'
                } {
                    echo -n '<span class="tag common">honest</span>'
                }
            }
            echo '<br />'
        }
%}

%       # Bio
%       if {isvisible bio && ! isempty $bio && !~ $^bio '<p><br></p>'} {
            <h2>Bio</h2>
            <div class="bio">%($bio%)</div>
%       }

%       # Social links
%       if {isvisible socials && {! isempty $vrchat || ! isempty $discord || ! isempty $steam ||
%           ! isempty $twitter || ! isempty $instagram || ! isempty $twitch || ! isempty $youtube ||
%           ! isempty $reddit || ! isempty $spotify || ! isempty $customurl}} {
            <h2>Socials</h2>
            <p>
%{
                if {! isempty $vrchat} {
                    echo 'VRChat: <a href="'$^vrchat'" target="_blank" rel="nofollow noopener">'`^{echo $^vrchat | sed 's/\/$//; s/.*\///; s/%20/ /g'}'</a><br />'
                }
                if {! isempty $discord} {
                    echo Discord: $^discord'<br />'
                }
                if {! isempty $steam} {
                    echo 'Steam: <a href="'$^steam'" target="_blank" rel="nofollow noopener">'`^{echo $^steam | sed 's/\/$//; s/.*\///; s/%20/ /g'}'</a><br />'
                }
                if {! isempty $twitter} {
                    echo 'Twitter: <a href="'$^twitter'" target="_blank" rel="nofollow noopener">@'`^{echo $^twitter | sed 's/\/$//; s/.*\///; s/%20/ /g'}'</a><br />'
                }
                if {! isempty $instagram} {
                    echo 'Instagram: <a href="'$^instagram'" target="_blank" rel="nofollow noopener">'`^{echo $^instagram | sed 's/\/$//; s/.*\///; s/%20/ /g'}'</a><br />'
                }
                if {! isempty $twitch} {
                    echo 'Twitch: <a href="'$^twitch'" target="_blank" rel="nofollow noopener">'`^{echo $^twitch | sed 's/\/$//; s/.*\///; s/%20/ /g'}'</a><br />'
                }
                if {! isempty $youtube} {
                    echo 'YouTube: <a href="'$^youtube'" target="_blank" rel="nofollow noopener">'`^{echo $^youtube | sed 's/\/$//; s/.*\///; s/%20/ /g'}'</a><br />'
                }
                if {! isempty $reddit} {
                    echo 'Reddit: <a href="'$^reddit'" target="_blank" rel="nofollow noopener">'`^{echo $^reddit | sed 's/\/$//; s/.*\///; s/%20/ /g'}'</a><br />'
                }
                if {! isempty $spotify} {
                    echo 'Spotify: <a href="'$^spotify'" target="_blank" rel="nofollow noopener">'`^{echo $^spotify | sed 's/\/$//; s/.*\///; s/%20/ /g'}'</a><br />'
                }
                if {! isempty $customurl} {
                    echo 'Website: <a href="'$^customurl'" title="'$^customurl'" target="_blank" rel="nofollow noopener" onclick="external_link(event, this)">'$^customurl'</a><br />'
                }
%}
            </p>
%       }

%{
        # Games
        if {logged_in} {
            common_games = `{redis_html `{redis graph read 'MATCH (u:user {username: '''$profile'''}),
                                                                  (lu:user {username: '''$logged_user'''}),
                                                                  (g:game)
                                                            WHERE (u)-[:PLAYS]->(g) AND
                                                                  (lu)-[:PLAYS]->(g)
                                                            RETURN g.name ORDER BY g.name'}}
            games = `{redis_html `{redis graph read 'MATCH (u:user {username: '''$profile'''}),
                                                           (lu:user {username: '''$logged_user'''}),
                                                           (g:game)
                                                     WHERE (u)-[:PLAYS]->(g) AND
                                                           NOT (lu)-[:PLAYS]->(g)
                                                     RETURN g.name ORDER BY g.name'}}
        } {
            games = `{redis_html `{redis graph read 'MATCH (u:user {username: '''$profile'''})-[:PLAYS]->(g:game)
                                                     RETURN g.name ORDER BY g.name'}}
        }
        if {isvisible games && {! isempty $games || ! isempty $common_games}} {
            echo '<h2>Fav social VR apps/games</h2>'
            if {! isempty $common_games} {
                for (game = $common_games) {
                    echo '<span class="tag common">'`^{echo $game | sed 's/_/ /g'}^'</span>'
                }
            }
            if {! isempty $games} {
                for (game = $games) {
                    echo '<span class="tag">'`^{echo $game | sed 's/_/ /g'}^'</span>'
                }
            }
        }

        # Interests
        if {isvisible interests_common || isvisible interests_uncommon} {
            echo '<h2>Interests</h2>'
            for (category = custom life creation genre gaming social; heading = Custom Life Creative Genre Gaming Social) {
                if {logged_in} {
                    common_tags = `{redis_html `{redis graph read 'MATCH (u:user {username: '''$profile'''})-[:INTERESTED_IN]->(t:tag {category: '''$category'''}),
                                                                         (lu:user {username: '''$logged_user'''})
                                                                   WHERE (lu)-[:INTERESTED_IN]->(t)
                                                                   RETURN t.name ORDER BY toLower(t.name)'}}
                    tags = `{redis_html `{redis graph read 'MATCH (u:user {username: '''$profile'''})-[:INTERESTED_IN]->(t:tag {category: '''$category'''}),
                                                                  (lu:user {username: '''$logged_user'''})
                                                            WHERE NOT (lu)-[:INTERESTED_IN]->(t)
                                                            RETURN t.name ORDER BY toLower(t.name)'}}
                } {
                    tags = `{redis_html `{redis graph read 'MATCH (u:user {username: '''$profile'''})-[:INTERESTED_IN]->(t:tag {category: '''$category'''})
                                                            RETURN t.name ORDER BY toLower(t.name)'}}
                }

                if {{isvisible interests_common && ! isempty $common_tags} || {isvisible interests_uncommon && ! isempty $tags}} {
                    echo '<h3>'$heading'</h3>'
                    if {isvisible interests_common && ! isempty $common_tags} {
                        for(tag = $common_tags) {
                            echo '<span class="tag common">'`^{echo $tag | sed 's/____/+/g; s/___/\//g; s/__/-/g; s/_/ /g'}^'</span>'
                        }
                    }
                    if {isvisible interests_uncommon && ! isempty $tags} {
                        for(tag = $tags) {
                            echo '<span class="tag">'`^{echo $tag | sed 's/____/+/g; s/___/\//g; s/__/-/g; s/_/ /g'}^'</span>'
                        }
                    }
                }
            }
        }

        # Language
        if {isvisible language} {
            echo '<h2>Language</h2>'
            if {logged_in} {
                common_languages = `{redis graph read 'MATCH (u:user {username: '''$profile'''}),
                                                      (lu:user {username: '''$logged_user'''}),
                                                      (l:language)
                                                WHERE (u)-[:KNOWS]->(l) AND
                                                      (lu)-[:KNOWS]->(l)
                                                RETURN l.id ORDER BY l.id'}
                languages = `{redis graph read 'MATCH (u:user {username: '''$profile'''}),
                                                      (lu:user {username: '''$logged_user'''}),
                                                      (l:language)
                                                WHERE (u)-[:KNOWS]->(l) AND
                                                      NOT (lu)-[:KNOWS]->(l)
                                                RETURN l.id ORDER BY l.id'}
            } {
                languages = `{redis graph read 'MATCH (u:user {username: '''$profile'''})-[:KNOWS]->(l:language)
                                                RETURN l.id ORDER BY l.id'}
            }
            if {! isempty $common_languages} {
                for (language = $common_languages) {
                    echo '<span class="tag common language">'$language'</span>'
                }
            }
            if {! isempty $languages} {
                for (language = $languages) {
                    echo '<span class="tag language">'$language'</span>'
                }
            }
        }

        # Platform
        if {isvisible platform} {
            echo '<h2>Platform</h2>'
            if {logged_in} {
                common_platforms = `{redis graph read 'MATCH (u:user {username: '''$profile'''}),
                                                             (lu:user {username: '''$logged_user'''}),
                                                             (p:platform)
                                                       WHERE (u)-[:USES]->(p) AND
                                                             (lu)-[:USES]->(p)
                                                       RETURN p.name ORDER BY p.name'}
                platforms = `{redis graph read 'MATCH (u:user {username: '''$profile'''}),
                                                      (lu:user {username: '''$logged_user'''}),
                                                      (p:platform)
                                                WHERE (u)-[:USES]->(p) AND
                                                      NOT (lu)-[:USES]->(p)
                                                RETURN p.name ORDER BY p.name'}
            } {
                platforms = `{redis graph read 'MATCH (u:user {username: '''$profile'''})-[:USES]->(p:platform)
                                                RETURN p.name ORDER BY p.name'}
            }
            if {! isempty $common_platforms} {
                for (platform = $common_platforms) {
                    echo '<span class="tag common">'`^{echo $platform | sed 's/_/ /g'}^'</span>'
                }
            }
            if {! isempty $platforms} {
                for (platform = $platforms) {
                    echo '<span class="tag">'`^{echo $platform | sed 's/_/ /g'}^'</span>'
                }
            }
        }
%}

%       if {!~ $profile $logged_user} {
            <br class="gap" />
%       }

%       # Unfriend button
%       if {~ $isfriend true} {
            <form action="/unfriend" method="POST" accept-charset="utf-8" style="display: inline-block; margin-right: 1em">
                    <input type="hidden" name="return" value="%($req_path%)">
                <input type="hidden" name="user" value="%($profile%)">
                <button type="submit" class="btn btn-blueraspberry btn-normal">Remove friend</button>
            </form>
%       }

%       # Report button
%       if {!~ $profile $logged_user} {
            <a href="/report?user=%($profile%)" class="btn btn-cherry btn-normal">Report user</a>
%       }

%       # Wave/friend button/info as applicable
%       if {logged_in && !~ $profile $logged_user && !~ $isfriend true && !~ $luwaved true} {
%           if {~ $uwaved true} {
                <form action="/wave" method="POST" accept-charset="utf-8" style="margin-top: 2.5em">
                    <input type="hidden" name="return" value="%($req_path%)">
                    <input type="hidden" name="user" value="%($profile%)">
                    <button type="submit" class="btn btn-mango">Add friend</button>
                </form>
%           } {
                <form action="/wave" method="POST" accept-charset="utf-8" style="margin-top: 2.5em">
                    <input type="hidden" name="return" value="%($req_path%)">
                    <input type="hidden" name="user" value="%($profile%)">
                    <button type="submit" class="btn btn-mango" title="This will send a friend request.">Wave</button>
                </form>
%           }
%       }
    </div>
% }

<script type="text/javascript">
    document.querySelectorAll('.country').forEach(function(country) {
        country.setAttribute('title', new Intl.DisplayNames([], {type: 'region'}).of(country.src.substr(-6, 2).toUpperCase()));
    });

    document.querySelectorAll('.language').forEach(function(language) {
        language.innerHTML = new Intl.DisplayNames([], {type: 'language'}).of(language.innerHTML);
    });
</script>
