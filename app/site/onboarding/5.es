require_login
if {! isempty $onboarding && !~ $onboarding 5} {
    post_redirect /
}

if {!~ $REQUEST_METHOD POST} { return 0 }

# Back button -> return to previous onboarding page
if {~ $p_back true} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''}) SET u.onboarding = 4'
    post_redirect /onboarding/4
}

# Validate and write avatar
referred = `{redis graph read 'MATCH (r:user)-[:REFERRED_BY]->(u:user {username: '''$logged_user'''}) RETURN count(r)'}
if {isempty $p_avatar ||
    ! echo $p_avatar | grep -s -e '^(defaults|food|hobbies|stuff|morestuff)/[0-9][0-9]$'} {
    p_avatar = 'defaults/01'
}

redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                   SET u.avatar = '''$p_avatar''''

# Proceed
if {! isempty $onboarding} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       SET u.genguestlist = true, u.onboarding = 6'
    post_redirect /onboarding/6
} {
    post_redirect '/settings#edit'
}
