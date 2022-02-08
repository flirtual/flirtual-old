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

# Add profile pics
redis graph write 'MATCH (u:user {username: '''$logged_user'''})-[:AVATAR]->(a:avatar)
                   DELETE a'
for (avatar = `{echo $post_args | tr ' ' $NEWLINE | grep '^p_pfp_[0-9]*$'}) {
    if {echo $$avatar | grep '^[a-z0-9/\-]*$'} {
        order = `{echo $avatar | sed 's/^p_pfp_//'}
        redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                           MERGE (u)-[:AVATAR]->(a:avatar {url: '''$$avatar''', order: '$order'})'
    }
}

# Validate bio
if {isempty $p_bio || ~ $p_bio '<p><br></p>'} {
    throw error 'Missing bio'
}

# Check newness
if {!~ $^p_new true} {
    p_new = false
}

# Validate and write games
redis graph write 'MATCH (u:user {username: '''$logged_user'''})-[r:PLAYS]->(g:game) DELETE r'
games = `^{redis graph read 'MATCH (g:game) RETURN g.name'}
for (game = `{echo $^p_games | sed 's/ /_/g; s/,/ /g'}) {
    if {in $game $games} {
        redis graph write 'MATCH (u:user {username: '''$logged_user'''}),
                                 (g:game {name: '''$game'''})
                           MERGE (u)-[:PLAYS]->(g)'
    }
}

# Validate and write tags
redis graph write 'MATCH (u:user {username: '''$logged_user'''})-[r:TAGGED]->(i:interest) DELETE r'
tags = `^{redis graph read 'MATCH (i:interest) RETURN i.name'}
for (tag = `{echo $^p_interests | sed 's/ /_/g; s/,/ /g' | escape_redis}) {
    existingtag = `{redis graph read 'MATCH (i:interest)
                                      WHERE toLower(i.name) = '''`^{echo $tag | tr 'A-Z' 'a-z'}^'''
                                      RETURN i.name'}
    if {isempty $existingtag} {
        # Create new tag
        redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                           MERGE (i:interest {name: '''$tag''', type: ''custom''})
                           MERGE (u)-[:TAGGED]->(i)'
    } {
        # Existing tag; link to user
        redis graph write 'MATCH (u:user {username: '''$logged_user'''}),
                                 (i:interest {name: '''$existingtag'''})
                           MERGE (u)-[:TAGGED]->(i)'
    }
}

# Fix URLs
if {! isempty $p_vrchat} {
    p_vrchat = `{echo $p_vrchat | sed 's/\/$//; s/.*\///; s/^/https:\/\/vrchat.com\/home\/search\//' | sanitize_url}
}

# Validate privacy setting
if {!~ $p_privacy vrlfp && !~ $p_privacy friends && !~ $p_privacy me} {
    throw error 'Invalid privacy setting'
}

# Write
redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                   SET u.bio = '''`^{echo $^p_bio | sed 's/\\//g' | bluemonday | 
                                     sed 's/<a /<a onclick="external_link(event, this)" /g' |
                                     escape_redis}^''',
                       u.new = '$p_new',
                       u.vrchat = '''`^{echo $^p_vrchat | escape_redis}^''',
                       u.discord = '''`^{echo $^p_discord | escape_redis}^''',
                       u.privacy_socials = '''$p_privacy''''

# Proceed
if {! isempty $onboarding} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       SET u.onboarding = 4'
    post_redirect /onboarding/4
} {
    post_redirect '/settings#edit'
}
