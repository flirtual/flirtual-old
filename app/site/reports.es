title = 'Reports'

require_login

if {!~ `{redis graph read 'MATCH (u:user {username: '''$logged_user'''}) RETURN u.mod'} true} {
    return 0
}
