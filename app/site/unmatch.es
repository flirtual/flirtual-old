require_login

if {!~ $REQUEST_METHOD POST} { return 0 }

# Validate user, existence
p_user = `{echo $p_user | grep '^[a-zA-Z0-9_\-]+$'}
(p_user id) = `` \n {redis graph read 'MATCH (u:user)
                                       WHERE u.username = '''$p_user''' OR
                                             u.id = '''$p_user'''
                                       RETURN u.username, u.id'}
if {isempty $p_user ||
    !~ `{redis graph read 'MATCH (a:user {username: '''$logged_user'''})
                                 -[m:MATCHED]-
                                 (b:user {username: '''$p_user'''})
                           RETURN exists(m)'} true} {
    if {echo $p_return | grep -s '^/[a-zA-Z0-9_\-]+$'} {
        # Follow redirect
        post_redirect $p_return
    } {
        # Or go home
        post_redirect /
    }
}

# Delete match
redis graph write 'MATCH (a:user {username: '''$logged_user'''})
                         -[m:MATCHED]-
                         (b:user {username: '''$p_user'''})
                   DELETE m'
redis graph write 'MATCH (a:user {username: '''$logged_user'''})
                         -[l:LIKED]->
                         (b:user {username: '''$p_user'''})
                   DELETE l'

#xmpp delete_rosteritem '{"localuser": "'$logged_user'", "localhost": "'$XMPP_HOST'", "user": "'$p_user'", "host": "'$XMPP_HOST'"}'
#xmpp delete_rosteritem '{"localuser": "'$p_user'", "localhost": "'$XMPP_HOST'", "user": "'$logged_user'", "host": "'$XMPP_HOST'"}'

compute_matches $logged_user $p_user

if {echo $p_return | grep -s '^/[a-zA-Z0-9_\-]+$'} {
    # Follow redirect
    post_redirect $p_return
} {
    # Or go home
    post_redirect /
}
