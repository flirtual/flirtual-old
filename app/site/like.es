require_login

if {!~ $REQUEST_METHOD POST} { return 0 }

# Validate users, like type
if {! echo $p_user | grep -s '^'$allowed_user_chars'+$' ||
    !~ `{redis graph read 'MATCH (u:user {username: '''$p_user'''}) RETURN exists(u)'} true ||
    !{~ $p_type homie || ~ $p_type date || ~ $p_type hookup}} {
    if {echo $p_return | grep -s '^/'$allowed_user_chars'+$'} {
        # Follow redirect
        post_redirect $p_return
    } {
        # Or go home
        post_redirect /
    }
}

# Create new like
redis graph write 'MATCH (a:user {username: '''$logged_user'''}),
                         (b:user {username: '''$p_user'''})
                   MERGE (a)-[:LIKED {type: '''$p_type''', date: '$dateun'}]->(b)'

redis graph write 'MATCH (a:user {username: '''$logged_user'''})
                         -[m:DAILYMATCH]-
                         (b:user {username: '''$p_user'''})
                   DELETE m'

# If user already liked logged_user, create match
if {~ `{redis graph read 'MATCH (a:user {username: '''$p_user'''})
                                -[l:LIKED]->
                                (b:user {username: '''$logged_user'''})
                          RETURN exists(l)'} true} {
    redis graph write 'MATCH (a:user {username: '''$p_user'''}),
                             (b:user {username: '''$logged_user'''})
                       MERGE (a)-[:MATCHED {date: '$dateun'}]->(b)'
    xmpp add_rosteritem '{"localuser": "'$logged_user'", "localhost": "'$XMPP_HOST'", "user": "'$p_user'", "host": "'$XMPP_HOST'", "nick": "'$p_user'", "group": "Friends", "subs": "both"}'
    xmpp add_rosteritem '{"localuser": "'$p_user'", "localhost": "'$XMPP_HOST'", "user": "'$logged_user'", "host": "'$XMPP_HOST'", "nick": "'$logged_user'", "group": "Friends", "subs": "both"}'
}

compute_matches $logged_user $p_user

if {echo $p_return | grep -s '^/'$allowed_user_chars'+$'} {
    # Follow redirect
    post_redirect $p_return
} {
    # Or go home
    post_redirect /
}
