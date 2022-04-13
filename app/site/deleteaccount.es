title = 'Delete Account'

require_login

if {!~ $REQUEST_METHOD POST} { return 0 }

# Verify password
rpassword = `{redis graph read 'MATCH (u:user {username: '''$logged_user'''}) RETURN u.password'}
if {! kryptgo checkhash -b $rpassword -p $p_password} {
    dprint Failed account deletion for $logged_user from $HTTP_USER_AGENT on $REMOTE_ADDR
    throw error 'Wrong password'
}

# Delete account
redis graph write 'MATCH (u:user {username: '''$logged_user'''}) DELETE u'
#xmpp unregister '{"user": "'$logged_user'", "host": "'$XMPP_HOST'"}'

# Logout
post_redirect /logout
