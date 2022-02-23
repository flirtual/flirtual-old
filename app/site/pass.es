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

# Pass on user (remove from future matchmaking)
redis graph write 'MATCH (a:user {username: '''$logged_user'''}),
                         (b:user {username: '''$p_user'''})
                   CREATE (a)-[p:PASSED {date: '$dateun'}]->(b)'

redis graph write 'MATCH (a:user {username: '''$logged_user'''})
                         -[m:DAILYMATCH]->
                         (b:user {username: '''$p_user'''})
                   DELETE m'

if {echo $p_return | grep -s '^/'$allowed_user_chars'+$'} {
    # Follow redirect
    post_redirect $p_return
} {
    # Or go home
    post_redirect /
}
