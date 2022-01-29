if {!~ `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})
                           RETURN u.admin'} true} {
    post_redirect /login
}
