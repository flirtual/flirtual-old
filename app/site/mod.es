require_login

if {!~ $REQUEST_METHOD POST ||
    !~ `{redis graph read 'MATCH (u:user {username: '''$logged_user'''}) RETURN u.admin'} true} {
    return 0
}

# Validate users, action
if {! echo $p_user | grep -s '^'$allowed_user_chars'+$' ||
    !~ `{redis graph read 'MATCH (u:user {username: '''$p_user'''}) RETURN exists(u)'} true ||
    {!~ $p_action ban && !~ $p_action unban}} {
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
}

post_redirect /$p_user
