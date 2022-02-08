if {logged_in} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       SET u.konami = NULL'
}
