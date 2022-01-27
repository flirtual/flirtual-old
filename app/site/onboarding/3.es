require_login
if {! isempty $onboarding && !~ $onboarding 3} {
    post_redirect /
}

if {!~ $REQUEST_METHOD POST} { return 0 }

# Back button -> return to previous onboarding page
if {~ $p_back true} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''}) SET u.onboarding = 2'
    post_redirect /onboarding/2
}

# Validate and write games
redis graph write 'MATCH (u:user {username: '''$logged_user'''})-[e:PLAYS]->(g:game) DELETE e'
games = `^{redis graph read 'MATCH (g:game) RETURN g.name'}
for (game = `{echo $^p_games | sed 's/ /_/g; s/,/ /g'}) {
    if {in $game $games} {
        redis graph write 'MATCH (u:user {username: '''$logged_user'''}),
                                 (g:game {name: '''$game'''})
                           MERGE (u)-[:PLAYS]->(g)'
    }
}

# Check newness
if {!~ $^p_new true} {
    p_new = false
}

# Fix URLs
if {! isempty $p_vrchat} {
    p_vrchat = `{echo $p_vrchat | sed 's/\/$//; s/.*\///; s/^/https:\/\/vrchat.com\/home\/search\//' | sanitize_url}
}
if {! isempty $p_steam} {
    p_steam = `{echo $p_steam | sed 's/\/$//; s/.*\///; s/^/https:\/\/steamcommunity.com\/id\//' | sanitize_url}
}
if {! isempty $p_twitter} {
    p_twitter = `{echo $p_twitter | sed 's/^@//; s/\/$//; s/.*\///; s/^/https:\/\/twitter.com\//' | sanitize_url}
}
if {! isempty $p_instagram} {
    p_instagram = `{echo $p_instagram | sed 's/\/$//; s/.*\///; s/^/https:\/\/instagram.com\//' | sanitize_url}
}
if {! isempty $p_twitch} {
    p_twitch = `{echo $p_twitch | sed 's/\/$//; s/.*\///; s/^/https:\/\/twitch.tv\//' | sanitize_url}
}
if {! isempty $p_youtube} {
    if {echo $p_youtube | grep -s '\..*/.'} {
        if {~ $p_youtube */channel/*} {
            p_youtube = https://www.youtube.com/channel/`{echo $p_youtube | sed 's/\/$//; s/.*\///'}
        } {~ $p_youtube */c/*} {
            p_youtube = https://www.youtube.com/c/`{echo $p_youtube | sed 's/\/$//; s/.*\///'}
        } {~ $p_youtube */user/*} {
            p_youtube = https://www.youtube.com/user/`{echo $p_youtube | sed 's/\/$//; s/.*\///'}
        } {
            p_youtube = https://www.youtube.com/`{echo $p_youtube | sed 's/\/$//; s/.*\///'}
        }
    } {echo $p_youtube | grep -s '^UC......................$'} {
        p_youtube = https://www.youtube.com/channel/$p_youtube
    } {
        p_youtube = https://www.youtube.com/$p_youtube
    }
    p_youtube = `{echo $p_youtube | sanitize_url}
}
if {! isempty $p_reddit} {
    p_reddit = `{echo $p_reddit | sed 's/\/$//; s/.*\///; s/^/https:\/\/www.reddit.com\/user\//' | sanitize_url}
}
if {! isempty $p_spotify} {
    p_spotify = `{echo $p_spotify | sed 's/\/$//; s/.*\///; s/^/https:\/\/open.spotify.com\/user\//' | sanitize_url}
}
if {! isempty $p_customurl} {
    p_customurl = `{echo $p_customurl | sanitize_url}
}

# Write
redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                   SET u.bio = '''`^{echo $^p_bio | sed 's/\\//g' | bluemonday | 
                                     sed 's/<a /<a onclick="external_link(event, this)" /g' |
                                     escape_redis}^''',
                       u.new = '$p_new',
                       u.vrchat = '''`^{echo $^p_vrchat | escape_redis}^''',
                       u.discord = '''`^{echo $^p_discord | escape_redis}^''',
                       u.steam = '''`^{echo $^p_steam | escape_redis}^''',
                       u.twitter = '''`^{echo $^p_twitter | escape_redis}^''',
                       u.instagram = '''`^{echo $^p_instagram | escape_redis}^''',
                       u.twitch = '''`^{echo $^p_twitch | escape_redis}^''',
                       u.youtube = '''`^{echo $^p_youtube | escape_redis}^''',
                       u.reddit = '''`^{echo $^p_reddit | escape_redis}^''',
                       u.spotify = '''`^{echo $^p_spotify | escape_redis}^''',
                       u.customurl = '''`^{echo $^p_customurl | escape_redis}^''''

# Start computing matches and proceed
if {! isempty $onboarding} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       SET u.genguestlist = true, u.onboarding = 4'
    post_redirect /onboarding/4
} {
    post_redirect '/settings#edit'
}
