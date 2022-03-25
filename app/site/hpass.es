require_login

if {!~ $REQUEST_METHOD POST} { return 0 }

# Validate user, existence
p_user = `{echo $p_user | grep '^[a-zA-Z0-9_\-]+$'}
(p_user id) = `` \n {redis graph read 'MATCH (u:user)
                                       WHERE u.username = '''$p_user''' OR
                                             u.id = '''$p_user'''
                                       RETURN u.username, u.id'}
if {isempty $p_user} {
    if {echo $p_return | grep -s '^/[a-zA-Z0-9_\-]+$'} {
        # Follow redirect
        post_redirect $p_return
    } {
        # Or go home
        post_redirect /
    }
}

# Pass on user (remove from homie mode queue only)
redis graph write 'MATCH (a:user {username: '''$logged_user'''}),
                         (b:user {username: '''$p_user'''})
                   MERGE (a)-[p:HPASSED {date: '$dateun'}]->(b)'

if {echo $p_return | grep -s '^/[a-zA-Z0-9_\-]+$'} {
    # Follow redirect
    post_redirect $p_return
} {
    # Or go home
    post_redirect /
}
