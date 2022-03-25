require_login

if {!~ $REQUEST_METHOD POST} { return 0 }

# Privacy settings
if {~ $p_changeprivacy true &&
    {~ $p_personality everyone || ~ $p_personality matches || ~ $p_personality me} &&
    {~ $p_socials everyone || ~ $p_socials matches || ~ $p_socials me} &&
    {~ $p_sexuality everyone || ~ $p_sexuality matches || ~ $p_sexuality me} &&
    {~ $p_country everyone || ~ $p_country matches || ~ $p_country me} &&
    {~ $p_optout true || ~ $p_optout false}} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       SET u.privacy_personality = '''$p_personality''',
                           u.privacy_socials = '''$p_socials''',
                           u.privacy_sexuality = '''$p_sexuality''',
                           u.privacy_country= '''$p_country''',
                           u.optout = '$p_optout

    # Kinks can be missing if the user has nsfw tags disabled, so set separately
    if {~ $p_kinks everyone || ~ $p_kinks matches || ~ $p_kinks me} {
        redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                           SET u.privacy_kinks = '''$p_kinks''''
    }

    post_redirect '/settings?update_success=Privacy%20settings'
}

# Notifications
if {~ $p_changenotifications true} {
    if {~ $p_match_emails true} {
        redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                           SET u.match_emails = true'
    } {
        redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                           SET u.match_emails= false'
    }
    if {~ $p_like_emails true} {
        redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                           SET u.like_emails = true'
    } {
        redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                           SET u.like_emails = false'
    }
    if {~ $p_newsletter true} {
        redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                           SET u.newsletter = true'
    } {
        redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                           SET u.newsletter = false'
    }

    if {echo $p_volume | grep -s -e '^0\.[0-9][0-9]?$' -e '^[0-1]$'} {
        redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                           SET u.volume = '$p_volume
    }

    post_redirect '/settings?update_success=Notification%20settings'
}

# Change email
if {~ $p_changeemail true &&
    ! isempty $p_newemail && ! isempty $p_confirmpassword} {
    # Verify current password
    rpassword = `{redis graph read 'MATCH (u:user {username: '''$logged_user'''}) RETURN u.password'}
    if {! kryptgo checkhash -b $rpassword -p $p_confirmpassword} {
        dprint Failed email change for $logged_user from $HTTP_USER_AGENT on $REMOTE_ADDR
        throw error 'Wrong password'
    }

    # Format email, check availability
    p_newemail = `{echo $p_newemail | tr 'A-Z' 'a-z' | escape_redis}
    if {~ `{redis graph read 'MATCH (u:user {email: '''$p_newemail'''}) RETURN exists(u)'} true} {
        throw error 'An account already exists with this email address'
    }

    # Generate confirm ID
    confirm = `{kryptgo genid}

    # Update email, create confirmation with expiry in 24 hours,
    # and return to email confirmation step of onboarding
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       SET u.email = '''$p_newemail''',
                           u.confirmed = false,
                           u.onboarding = 5
                       MERGE (c:confirm {id: '''$confirm''', expiry: '`{+ $dateun 86400}^'})
                       MERGE (u)-[:CONFIRM]->(c)'

    # Email confirmation
    sed 's/\$confirm/'$confirm'/' < mail/confirm | email $logged_user 'Please confirm your email'

    post_redirect /onboarding/5
}

# Change password
if {~ $p_changepassword true &&
    ! isempty $p_currentpassword && ! isempty $p_newpassword} {
    # Verify current password
    rpassword = `{redis graph read 'MATCH (u:user {username: '''$logged_user'''}) RETURN u.password'}
    if {! kryptgo checkhash -b $rpassword -p $p_currentpassword} {
        dprint Failed password change for $logged_user from $HTTP_USER_AGENT on $REMOTE_ADDR
        throw error 'Wrong password'
    }

    # Validate new password
    if {le `{echo $p_newpassword | wc -c} 8} {
        throw error 'Your password must be at least 8 characters long'
    }

    # Update password
    redis graph write 'MATCH (u:user {username: '''$logged_user'''}) SET u.password = '''`{kryptgo genhash -p $p_newpassword}^''''

    post_redirect '/settings?update_success=Password'
}
