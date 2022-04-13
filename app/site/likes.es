title = 'Likes'

require_login

if {!~ `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})
                           RETURN exists(u.premium)'} true} {
    post_redirect /premium
}
