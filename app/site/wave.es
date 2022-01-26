require_login

if {!~ $REQUEST_METHOD POST} { return 0 }

# Validate user, existence
if {! echo $p_user | grep -s '^'$allowed_user_chars'+$' ||
    !~ `{redis graph read 'MATCH (u:user {username: '''$p_user'''}) RETURN exists(u)'} true} {
    if {echo $p_return | grep -s '^/'$allowed_user_chars'+$'} {
        # Follow redirect
        post_redirect $p_return
    } {
        # Or go home
        post_redirect /
    }
}

if {~ `{redis graph read 'MATCH (a:user {username: '''$p_user'''})-[r:WAVED]->(b:user {username: '''$logged_user'''})
                          RETURN exists(r)'} true} {
    # User had already waved at logged_user, add friend
    redis graph write 'MATCH (a:user {username: '''$p_user'''})-[r:WAVED]->(b:user {username: '''$logged_user'''})
                       DELETE r
                       MERGE (a)-[:FRIENDS {new: true}]->(b)'
    xmpp add_rosteritem '{"localuser": "'$logged_user'", "localhost": "'$XMPP_HOST'", "user": "'$p_user'", "host": "'$XMPP_HOST'", "nick": "'$p_user'", "group": "Friends", "subs": "both"}'
    xmpp add_rosteritem '{"localuser": "'$p_user'", "localhost": "'$XMPP_HOST'", "user": "'$logged_user'", "host": "'$XMPP_HOST'", "nick": "'$logged_user'", "group": "Friends", "subs": "both"}'

    # Email notification for first waver
    sed 's/\$user/'$logged_user'/' < mail/friend | email $p_user 'You have a new friend on ROVR!'
} {
    # Create new wave
    redis graph write 'MATCH (a:user {username: '''$logged_user'''}),
                             (b:user {username: '''$p_user'''})
                       MERGE (a)-[:WAVED {email: true}]->(b)'

    # Email notification
    send = `{redis graph read 'MATCH (u:user {username: '''$p_user'''}) RETURN u.email_wave'}
    if {~ $send each} {
        email $p_user 'Someone waved at you!' < mail/wave
    }
}

if {echo $p_return | grep -s '^/'$allowed_user_chars'+$'} {
    # Follow redirect
    post_redirect $p_return
} {
    # Or go home
    post_redirect /
}
