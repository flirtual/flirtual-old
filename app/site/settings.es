require_login

if {!~ $REQUEST_METHOD POST} { return 0 }

# Theme
if {~ $p_changetheme true &&
    {~ $p_theme light || ~ $p_theme dark}} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       SET u.theme = '''$p_theme''''

    post_redirect '/settings?update_success=Theme'
}

# Privacy settings
if {~ $p_changeprivacy true &&
    {~ $p_age public || ~ $p_age rovr || ~ $p_age friends || ~ $p_age me} &&
    {~ $p_gender public || ~ $p_gender rovr || ~ $p_gender friends || ~ $p_gender me} &&
    {~ $p_country public || ~ $p_country rovr || ~ $p_country friends || ~ $p_country me} &&
    {~ $p_interests_common rovr || ~ $p_interests_common friends || ~ $p_interests_common me} &&
    {~ $p_interests_uncommon public || ~ $p_interests_uncommon rovr || ~ $p_interests_uncommon friends || ~ $p_interests_uncommon me} &&
    {~ $p_bio public || ~ $p_bio rovr || ~ $p_bio friends || ~ $p_bio me} &&
    {~ $p_language public || ~ $p_language rovr || ~ $p_language friends || ~ $p_language me} &&
    {~ $p_platform public || ~ $p_platform rovr || ~ $p_platform friends || ~ $p_platform me} &&
    {~ $p_games public || ~ $p_games rovr || ~ $p_games friends || ~ $p_games me} &&
    {~ $p_socials public || ~ $p_socials rovr || ~ $p_socials friends || ~ $p_socials me} &&
    {~ $p_friends rovr || ~ $p_friends friends || ~ $p_friends hidden} &&
    {~ $p_invite public || ~ $p_invite hidden} &&
    {~ $p_optout true || ~ $p_optout false}} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       SET u.privacy_age = '''$p_age''',
                           u.privacy_gender = '''$p_gender''',
                           u.privacy_country = '''$p_country''',
                           u.privacy_socials = '''$p_socials''',
                           u.privacy_games = '''$p_games''',
                           u.privacy_interests_common = '''$p_interests_common''',
                           u.privacy_interests_uncommon = '''$p_interests_uncommon''',
                           u.privacy_bio = '''$p_bio''',
                           u.privacy_language = '''$p_language''',
                           u.privacy_platform = '''$p_platform''',
                           u.privacy_friends = '''$p_friends''',
                           u.privacy_invite = '''$p_invite''',
                           u.optout = '$p_optout

    post_redirect '/settings?update_success=Privacy%20settings'
}

# Notifications
if {~ $p_changenotifications true} {
    if {~ $p_newsletter true} {
        redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                           SET u.newsletter = true'
    } {
        redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                           SET u.newsletter = false'
    }

    if {~ $p_email_wave each} {
        redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                           SET u.email_wave = ''each'''
    } {~ $p_email_wave digest} {
        redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                           SET u.email_wave = ''digest'''
    } {~ $p_email_wave disabled} {
        redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                           SET u.email_wave = ''disabled'''
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
                           u.onboarding = 7
                       CREATE (u)-[:CONFIRM]->(c:confirm {id: '''$confirm''', expiry: '`{+ $dateun 86400}^'})'

    # Email confirmation
    sed 's/\$confirm/'$confirm'/' < mail/confirm | email $logged_user 'Please confirm your email'

    post_redirect /onboarding/7
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
