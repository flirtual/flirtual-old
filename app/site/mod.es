require_login

if {!~ $REQUEST_METHOD POST ||
    !~ `{redis graph read 'MATCH (u:user {username: '''$logged_user'''}) RETURN u.mod'} true} {
    return 0
}

# Validate users
if {! echo $p_user | grep -s '^'$allowed_user_chars'+$' ||
    !~ `{redis graph read 'MATCH (u:user {username: '''$p_user'''}) RETURN exists(u)'} true} {
    post_redirect /
}

if {~ $p_action ban} {
    redis graph write 'MATCH (u:user {username: '''$p_user'''})
                       SET u.banned = true'
    redis graph write 'MATCH (a:user)-[m:DAILYMATCH]->(b:user {username: '''$p_user'''})
                       DELETE m'
} {~ $p_action unban} {
    redis graph write 'MATCH (u:user {username: '''$p_user'''})
                       SET u.banned = NULL'
} {~ $p_action verify && ~ `{redis graph read 'MATCH (u:user {username: '''$logged_user'''}) RETURN u.admin'} true} {
    if {~ `{redis graph read 'MATCH (u:user {username: '''$p_user'''})
                              RETURN exists(u.verified)'} false} {
        redis graph write 'MATCH (u:user {username: '''$p_user'''})
                           SET u.verified = true'
    } {
        redis graph write 'MATCH (u:user {username: '''$p_user'''})
                           SET u.verified = NULL'
    }
}

post_redirect /$p_user
