%{
if {! isempty $targ} {
    profile = $targ
} {
    profile = `{echo $req_path | sed 's/\/$//; s/.*\///'}
}

(id profile serious luserious monopoly lumonopoly displayname dob country country_id ismatch \
 passed uliked luliked lastlogin new lunew open luopen conscientious luconscientious agreeable \
 luagreeable bio vrchat discord domsub ludomsub onboarding vrlfp privacy_personality \
 privacy_socials privacy_sexuality privacy_kinks nsfw luadmin admin lumod mod verified \
 earlysupporter supporter_badge banned email) = \
    `` \n {redis graph read 'MATCH (u:user)
                             WHERE toLower(u.username) = '''`{echo $profile | tr 'A-Z' 'a-z'}^''' OR
                                   u.id = '''$profile'''
                             OPTIONAL MATCH (lu:user {username: '''$^logged_user'''})
                             OPTIONAL MATCH (u)-[matched:MATCHED]-(lu)
                             OPTIONAL MATCH (u)-[uliked:LIKED]->(lu)
                             OPTIONAL MATCH (lu)-[luliked:LIKED]->(u)
                             OPTIONAL MATCH (lu)-[passed:PASSED]->(u)
                             OPTIONAL MATCH (u)-[:COUNTRY]->(c:country)
                             RETURN u.id, u.username, u.serious, lu.serious, u.monopoly,
                                    lu.monopoly, u.displayname, u.dob, c.name, toLower(c.id),
                                    exists(matched), exists(passed), exists(uliked),
                                    exists(luliked), u.lastlogin, u.new, u.lunew, sign(u.openness),
                                    sign(lu.openness), sign(u.conscientiousness),
                                    sign(lu.conscientiousness), sign(u.agreeableness),
                                    sign(lu.agreeableness), u.bio, u.vrchat, u.discord, u.domsub,
                                    lu.domsub, exists(u.onboarding), exists(u.vrlfp),
                                    u.privacy_personality, u.privacy_socials, u.privacy_sexuality,
                                    u.privacy_kinks, lu.nsfw, exists(lu.admin), exists(u.admin),
                                    exists(lu.mod), exists(u.mod), exists(u.verified),
                                    exists(u.earlysupporter), exists(u.supporter_badge),
                                    exists(u.banned), u.email'}

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
% if {isempty $profile || {~ $onboarding true && ~ $vrlfp false} || {~ $banned true && !~ $luadmin true}} {
      <div class="box" style="margin-top: 0">
          <h1>404</h1>
          <p>Sorry, the profile you're looking for doesn't exist!</p>
      </div>
% } {
%     # Like/matched info as applicable
%     if {!~ $profile $logged_user && !~ $ismatch true} {
%         if {~ $luliked true && !~ $req_path /} {
              <div class="match_info">
                  <div class="notice">You liked %($displayname%).</div>
                  <form action="/undo" method="POST" accept-charset="utf-8">
                      <input type="hidden" name="user" value="%($id%)">
                      <button type="submit" class="btn btn-normal">
                          <img src="/img/undo.svg" />
                          <span class="desktop">Undo</span>
                      </button>
                  </form>
              </div>
%         } {~ $passed true && !~ $req_path /} {
              <div class="match_info">
                  <div class="notice">You passed on %($displayname%).</div>
                  <form action="/undo" method="POST" accept-charset="utf-8">
                      <input type="hidden" name="user" value="%($id%)">
                      <button type="submit" class="btn btn-normal">
                          <img src="/img/undo.svg" />
                          <span class="desktop">Undo</span>
                      </button>
                  </form>
              </div>
%         } {
              <div class="buttons_top">
%                 if {!~ $req_path /homies && !~ $p_return /homies} {
%                     if {~ $req_path / || ~ $req_path /undo} {
                          <form action="/undo" method="POST" accept-charset="utf-8">
                              <button type="submit" class="btn btn-normal">
                                  <img src="/img/undo.svg" />
                                  <span class="desktop">Undo</span>
                              </button>
                          </form>
%                     }
                      <form action="/like" method="POST" accept-charset="utf-8">
%                         if {~ $q_return /likes} {
                              <input type="hidden" name="return" value="/matches">
%                         } {~ $req_path /undo} {
                              <input type="hidden" name="return" value="/">
%                         } {
                              <input type="hidden" name="return" value="%($req_path%)">
%                         }
                          <input type="hidden" name="user" value="%($id%)">
                          <input type="hidden" name="type" value="like">
                          <button type="submit" class="btn btn-gradient btn-normal" style="padding-left: 13px">
                              <img src="/img/like.svg" />
                              <span>Like</span>
                          </button>
                      </form>
                      <form action="/like" method="POST" accept-charset="utf-8">
%                         if {~ $q_return /likes} {
                              <input type="hidden" name="return" value="/matches">
%                         } {~ $req_path /undo} {
                              <input type="hidden" name="return" value="/">
%                         } {
                              <input type="hidden" name="return" value="%($req_path%)">
%                         }
                          <input type="hidden" name="user" value="%($id%)">
                          <input type="hidden" name="type" value="homie">
                          <button type="submit" class="btn btn-gradient btn-normal" style="padding-left: 13px">
                              <img src="/img/homie.svg" />
                              <span>Homie</span>
                          </button>
                      </form>
                      <form action="/pass" method="POST" accept-charset="utf-8">
%                         if {~ $q_return /likes} {
                              <input type="hidden" name="return" value="/likes">
%                         } {~ $req_path /undo} {
                              <input type="hidden" name="return" value="/">
%                         } {
                              <input type="hidden" name="return" value="%($req_path%)">
%                         }
                          <input type="hidden" name="user" value="%($id%)">
                          <button type="submit" class="btn btn-normal">
                              <img src="/img/pass.svg" />
                              <span class="desktop">Pass</span>
                          </button>
                      </form>
%                 } {
                          <form action="/undo" method="POST" accept-charset="utf-8">
                              <input type="hidden" name="return" value="/homies">
                              <button type="submit" class="btn btn-normal">
                                  <img src="/img/undo.svg" />
                                  <span class="desktop">Undo</span>
                              </button>
                          </form>
                      <form action="/like" method="POST" accept-charset="utf-8">
                          <input type="hidden" name="return" value="/homies">
                          <input type="hidden" name="user" value="%($id%)">
                          <input type="hidden" name="type" value="homie">
                          <button type="submit" class="btn btn-gradient btn-normal" style="padding-left: 13px">
                              <img src="/img/homie.svg" />
                              <span>Homie</span>
                          </button>
                      </form>
                      <form action="/hpass" method="POST" accept-charset="utf-8">
                          <input type="hidden" name="return" value="/homies">
                          <input type="hidden" name="user" value="%($id%)">
                          <button type="submit" class="btn btn-normal">
                              <img src="/img/pass.svg" />
                              <span class="desktop">Pass</span>
                          </button>
                      </form>
%                 }
              </div>
%         }
%     } {~ $profile $logged_user} {
          <div class="center" style="margin-top: -100px"><a href="/settings#edit" class="btn center">Edit profile</a></div>
%     }

%     # Ban info
%     if {~ $banned true && ~ $luadmin true} {
          <div class="box contact">
              <p>%($profile%) (%($email%)) has been banned.</p>
              <form action="/mod" method="POST" accept-charset="utf-8">
                  <input type="hidden" name="action" value="unban">
                  <input type="hidden" name="user" value="%($profile%)">
                  <button type="submit" class="btn btn-gradient">Unban user</button>
              </form>
          </div>
%     }

%     # Contact
%     if {~ $ismatch true} {
          <div class="center">
              <p style="margin-top: -100px">It's a match!</p>
              <a href="#converse/chat?jid=%($profile%)@%($XMPP_HOST%)" class="btn btn-gradient">Message</a>
%             if {~ $q_return /} {
                  <a href="/" class="btn">Keep browsing</a>
%             }
          </div>
%     }
%     if {isvisible socials && {! isempty $vrchat || ! isempty $discord}} {
          <div class="box contact">
%             if {isvisible socials && ! isempty $vrchat} {
                  <img style="transform: translateY(4px) scale(1.3)" src="/img/vrchat.svg" width="30" height="24" />
                  <strong>VRChat:</strong>
                  <a href="%($^vrchat%)" target="_blank" rel="nofollow noopener">
%                     echo $^vrchat | sed 's/\/$//; s/.*\///; s/%20/ /g' | urldecode
                  </a><br />
%             }
%             if {isvisible socials && ! isempty $discord} {
                  <img src="/img/discord.svg" width="30" height="24" />
                  <strong>Discord:</strong>
                  %($^discord%)<br />
%             }
          </div>
%     }

%     avatars = `{redis graph read 'MATCH (u:user {username: '''$profile'''})-[:AVATAR]->(a:avatar)
%                                   RETURN DISTINCT a.url ORDER BY a.order LIMIT 15'}
%     i = 0
%     for (avatar = $avatars) {
          <a href="#_" class="lightbox" id="pfp%($i%)">
              <span style="background-image: url('https://media.flirtu.al/%(`{echo $avatar | sed 's/\/.*//'}%)/')"></span>
          </a>
%         ++ i
%     }
      <div class="box profile">
          <div class="pfps">
              <div class="swiper">
                  <div class="swiper-wrapper">
%                     i = 0
%                     for (avatar = $avatars) {
                          <div class="swiper-slide">
                              <a href="#pfp%($i%)" class="desktop">
                                  <img data-blink-ops="scale-crop: 1920x1080; scale-crop-position: smart_faces_points"
                                       data-blink-uuid="%($avatar%)" />
                              </a>
                              <a href="#pfp%($i%)" class="mobile">
                                  <img data-blink-ops="scale-crop: 1920x1920; scale-crop-position: smart_faces_points"
                                       data-blink-uuid="%($avatar%)" />
                              </a>

%                             if {~ $lumod true && !~ $avatar 'e8212f93-af6f-4a2c-ac11-cb328bbc4aa4'} {
                                  <form action="/mod" method="POST" accept-charset="utf-8"
                                        onsubmit="return confirm('Are you sure you want to ban this image?')">
                                      <input type="hidden" name="action" value="rmpfp">
                                      <input type="hidden" name="user" value="%($profile%)">
                                      <input type="hidden" name="avatar" value="%($avatar%)">
                                      <button type="submit" class="rmpfp" aria-label="Ban image" role="tooltip" data-microtip-position="left">🗑️</button>
                                  </form>
%                             }
                          </div>
%                         ++ i
%                     }
                  </div>
                  <div class="swiper-button-prev"></div>
                  <div class="swiper-button-next"></div>
              </div>

              <div class="name">
                  <h2>%($displayname%)</h2>
              </div>

              <div class="asl">
%                 # Age
%                 age = `{int `{/ `{- `{yyyymmdd `{date -u | sed 's/  / 0/'}} `{echo $dob | sed 's/-//g'}} 10000}}
%                 if {le $age 125} {
                      <span class="tag">
                          %($age%)
                      </span>
%                 }

%                 # Gender
%                 genders = `` \n {redis graph read 'MATCH (u:user {username: '''$profile'''})-[:GENDER]->(g:gender)
%                                                   RETURN g.name
%                                                   ORDER BY g.order LIMIT 5' | sed 's/_/ /g'}
%                 if {! isempty $genders} {
%                     for (gender = $genders) {
                          <span class="tag">%($gender%)</span>
%                     }
%                 }

%                 # Location
%                 if {! isempty $country} {
                      <span class="tag">
                          <span class="country_name" style="margin-right: 41px">%(`{echo $country | sed 's/_/ /g'}%)</span>
                          <span style="position: absolute; transform: translate(-31px, -3px)">
                              <img class="country" onerror="this.style.visibility='hidden'"
                                   src="/img/flags/%($country_id%).svg" width="33" height="25" />
                          </span>
                      </span>
%                 }

%                 # Badges
%                 if {~ $admin true || ~ $mod true || ~ $verified true || ~ $earlysupporter true ||
%                     ~ $supporter_badge true} {
                      <span class="tag badges">
%                         if {~ $admin true} {
                              <span aria-label="Flirtual Staff" role="tooltip" data-microtip-position="top">👑</span>
%                         }
%                         if {~ $mod true} {
                              <span aria-label="Moderator" role="tooltip" data-microtip-position="top">🛡️</span>
%                         }
%                         if {~ $verified true} {
                              <span aria-label="Verified Profile" role="tooltip" data-microtip-position="top">✅</span>
%                         }
%                         if {~ $earlysupporter true} {
                              <span aria-label="Early Supporter" role="tooltip" data-microtip-position="top">💖</span>
%                         }
%                         if {~ $supporter_badge true} {
                              <span aria-label="Supporter" role="tooltip" data-microtip-position="top">🌟</span>
%                         }
                      </span>
%                 }

%                 # Last online
%                 if {! isempty $lastlogin} {
%                     since_lastlogin = `{- $dateun $lastlogin}
%                     if {lt $since_lastlogin 2764800} {
                          <span class="lastonline">Active
%                             if {lt $since_lastlogin 172800} {
                                  today
%                             } {lt $since_lastlogin 691200} {
                                  this week
%                             } {
                                  this month
%                             }
                          </span>
%                     }
%                 }
              </div>
          </div>

%         # New user?
%         if {!~ $profile $logged_user} {
%             if {~ $new true && ~ $lunew true} {
                  <p style="margin-top: 45px"><em>You're both new to VR. Explore it together!</em></p>
%             } {~ $new true} {
                  <p style="margin-top: 45px"><em>%($displayname%) is new to VR. Show them around!</em></p>
%             }
%         }

%         # Bio
%         if {! isempty $bio} {
              <h2 style="margin: 45px 0 -40px">About Me</h2>
              <div class="bio">%($bio%)</div>
%         } {
              <br />
%         }

%{
          echo '<div>'

          # Open to serious dating
          if {~ $^serious true} {
              echo '<div class="tags">'
              echo '<span class="tag '`^{if {~ $serious $luserious} { echo common }}^'">Open to serious dating</span>'
              echo '</div>'
          }

          # Sexuality
          sexualities = `` \n {redis graph read 'MATCH (u:user {username: '''$profile'''})-[:SEXUALITY]->(s:sexuality)
                                                 RETURN s.name
                                                 ORDER BY s.order LIMIT 3' | sed 's/_/ /g'}
          if {isvisible sexuality && ! isempty $sexualities} {
              echo '<div class="tags">'
              for (sexuality = $sexualities) {
                  echo '<span class="tag '`^{if {~ $profile $logged_user} { echo common }}^'">'$sexuality'</span>'
              }
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
              if {{~ $domsub Dominant && ~ $ludomsub Submissive} ||
                  {~ $domsub Submissive && ~ $ludomsub Dominant} ||
                  {~ $domsub Switch && ~ $ludomsub Switch}} {
                  echo '<span class="tag common">'$domsub'</span>'
              } {
                  echo '<span class="tag">'$domsub'</span>'
              }
              echo '</div>'
          }

          echo '</div>'
          echo '<a id="morebtn" class="btn" onclick="toggleMore()" style="font-size: 24px; margin: 28px 0 -2px 0">More info &#x25BC;</a>'
          echo '<div id="more" style="display: none; margin: -8px 0 -23px 0">'

          # (Non-)monogamous
          if {! isempty $monopoly} {
              echo '<div class="tags">'
              echo '<span class="tag '`^{if {~ $monopoly $lumonopoly} { echo common }}^'">'$monopoly'</span>'
              echo '</div>'
          }

          # Kinks
          kinks = `{redis_html `{redis graph read 'MATCH (u:user {username: '''$profile'''})-[:KINK]->(k:kink),
                                                         (lu:user {username: '''$logged_user'''})
                                                   RETURN k.name ORDER BY k.order'}}
          if {~ $nsfw true && isvisible kinks && ! isempty $kinks} {
              echo '<div class="tags">'
              for (kink = $kinks) {
                  echo '<span class="tag">'^`^{echo $kink | sed 's/_/ /g'}^'</span>'
              }
              echo '</div>'
          }

          # Language
          common_languages = `{redis_html `{redis graph read 'MATCH (u:user {username: '''$profile'''})
                                                                    -[:KNOWS]->(l:language)<-[:KNOWS]-
                                                                    (lu:user {username: '''$logged_user'''})
                                                              RETURN l.name ORDER BY l.name'}}
          languages = `{redis_html `{redis graph read 'MATCH (u:user {username: '''$profile'''})
                                                             -[:KNOWS]->(l:language),
                                                             (lu:user {username: '''$logged_user'''})
                                                       WHERE NOT (lu)-[:KNOWS]->(l)
                                                       RETURN l.name ORDER BY l.name'}}
          if {! isempty $languages || ! isempty $common_languages} {
              echo '<div class="tags">'
              if {! isempty $common_languages} {
                  for (language = $common_languages) {
                      echo '<span class="tag common">'^`^{echo $language | sed 's/_/ /g'}^'</span>'
                  }
              }
              if {! isempty $languages} {
                  for (language = $languages) {
                      echo '<span class="tag">'^`^{echo $language | sed 's/_/ /g'}^'</span>'
                  }
              }
              echo '</div>'
          }

          # VR setup
          common_platforms = `{redis_html `{redis graph read 'MATCH (u:user {username: '''$profile'''})
                                                                    -[:USES]->(p:platform)<-[:USES]-
                                                                    (lu:user {username: '''$logged_user'''})
                                                              RETURN p.name ORDER BY p.order'}}
          platforms = `{redis_html `{redis graph read 'MATCH (u:user {username: '''$profile'''})
                                                             -[:USES]->(p:platform),
                                                             (lu:user {username: '''$logged_user'''})
                                                       WHERE NOT (lu)-[:USES]->(p)
                                                       RETURN p.name ORDER BY p.order'}}
          if {! isempty $platforms || ! isempty $common_platforms} {
              echo '<div class="tags">'
              if {! isempty $common_platforms} {
                  for (platform = $common_platforms) {
                      echo '<span class="tag common">'^`^{echo $platform | sed 's/_/ /g'}^'</span>'
                  }
              }
              if {! isempty $platforms} {
                  for (platform = $platforms) {
                      echo '<span class="tag">'^`^{echo $platform | sed 's/_/ /g'}^'</span>'
                  }
              }
              echo '</div>'
          }

          echo '</div>'
%}
      </div>

%     if {!~ $profile $logged_user} {
          <div class="buttons_bottom">
%             # Unmatch button
%             if {~ $ismatch true} {
                  <form action="/unmatch" method="POST" accept-charset="utf-8" style="display: inline-block; margin-right: 1em">
                      <input type="hidden" name="return" value="%($req_path%)">
                      <input type="hidden" name="user" value="%($id%)">
                      <button type="submit" class="btn btn-normal">Unmatch</button>
                  </form>
%             }

%             # Report/ban button
%             if {!~ $profile $logged_user} {
%                 if {~ $lumod true} {
                      <form action="/mod" method="POST" accept-charset="utf-8">
                          <input type="hidden" name="action" value="ban">
                          <input type="hidden" name="user" value="%($profile%)">
                          <div style="display: inline-block; margin-right: 1em; transform: translateY(-25px)">
                              <label for="reason">Reason:</label>
                              <input type="text" name="reason" id="reason" style="width: auto">
                          </div>
                          <button type="submit" class="btn btn-normal">Ban user</button>
                      </form>
%                     reports = `{redis graph read 'MATCH (r:user)
%                                                         -[:REPORTED {reviewed: false}]->
%                                                         (u:user {username: '''$profile'''})
%                                                   RETURN count(r)'}
%                     if {! isempty $reports && gt $reports 0} {
                          <form action="/mod" method="POST" accept-charset="utf-8">
                              <input type="hidden" name="action" value="clear">
                              <input type="hidden" name="user" value="%($profile%)">
                              <button type="submit" class="btn btn-normal">Clear %($reports%) reports</button>
                          </form>
%                     }
%                 } {
                      <form action="/report" method="POST" accept-charset="utf-8">
                          <input type="hidden" name="user" value="%($id%)">
                          <button type="submit" class="btn btn-normal">Report user</button>
                      </form>
%                 }
%                 if {~ $luadmin true} {
                      <form action="/mod" method="POST" accept-charset="utf-8">
                          <input type="hidden" name="action" value="verify">
                          <input type="hidden" name="user" value="%($profile%)">
                          <button type="submit" class="btn btn-normal">Verify user</button>
                      </form>
%                 }
%             }
          </div>
%     }
% }

<script type="text/javascript">
    window.addEventListener("load", function(event) {
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

    function toggleMore() {
        var more = document.getElementById("more");
        if (more.style.display === "none") {
            more.style.display = "block";
            morebtn.innerHTML = "Less info &#x25B2;";
        } else {
            more.style.display = "none";
            morebtn.innerHTML = "More info &#x25BC;";
        }
    }
</script>
