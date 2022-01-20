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

# Remove user from friends list
redis graph write 'MATCH (a:user {username: '''$logged_user'''})-[f:FRIENDS]-(b:user {username: '''$p_user'''})
                   DELETE f'
xmpp delete_rosteritem '{"localuser": "'$logged_user'", "localhost": "'$XMPP_HOST'", "user": "'$p_user'", "host": "'$XMPP_HOST'", "nick": "'$p_user'", "group": "Friends", "subs": "both"}'
xmpp delete_rosteritem '{"localuser": "'$p_user'", "localhost": "'$XMPP_HOST'", "user": "'$logged_user'", "host": "'$XMPP_HOST'", "nick": "'$logged_user'", "group": "Friends", "subs": "both"}'

if {echo $p_return | grep -s '^/'$allowed_user_chars'+$'} {
    # Follow redirect
    post_redirect $p_return
} {
    # Or go home
    post_redirect /
}
