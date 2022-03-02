if {!~ $REQUEST_METHOD POST ||
    ~ $p_from_landingpage true} {
    return 0
}

(uexists eexists reserved) = `` \n {redis graph read 'OPTIONAL MATCH (uu:user)
                                                      WHERE toLower(uu.username) = '''`^{echo $p_username | tr 'A-Z' 'a-z'}^'''
                                                      OPTIONAL MATCH (ue:user {email: '''$p_email'''})
                                                      OPTIONAL MATCH (ur:reserved {username: '''`^{echo $p_username | tr 'A-Z' 'a-z'}^'''})
                                                      RETURN exists(uu), exists(ue), exists(ur)'}

# Validate username, availability
if {isempty $p_username || ! echo $p_username | grep -s '^'$allowed_user_chars'+$'} {
    throw error 'Invalid username. Allowed characters: [<pre>a-z, A-Z, 0-9, _</pre>]'
}
if {~ $uexists true || ~ $reserved true || test -e site/$p_username || test -e site/$p_username.*} {
    throw error 'An account already exists with this username. Please choose another'
}

# Validate email, availability
if {isempty $p_email} {
    throw error 'Missing email address'
}
p_email = `{echo $p_email | tr 'A-Z' 'a-z' | escape_redis}
if {~ $eexists true} {
    throw error 'An account already exists with this email address'
}
# Validate password
if {isempty $p_password ||
    le `{echo $p_password | wc -c} 8} {
    throw error 'Your password must be at least 8 characters long'
}

# Check ToS/PP, newsletter, theme
if {!~ $p_tos true} {
    throw error 'You must agree to the Terms of Service and the Privacy Policy to use Flirtual'
}

if {!~ $p_newsletter true} { p_newsletter = false }

# Validate hCaptcha
if {! hcaptcha $p_hcaptcharesponse} {
    throw error 'Captcha failed'
}

# Create user and confirmation
confirm = `{kryptgo genid}

redis graph write 'MERGE (u:user {username: '''$p_username'''})
                   ON CREATE SET u.displayname = '''$p_username''',
                                 u.email = '''$p_email''',
                                 u.password = '''`{kryptgo genhash -p $p_password}^''',
                                 u.newsletter = '$p_newsletter',
                                 u.onboarding = 1,
                                 u.privacy_personality = ''everyone'',
                                 u.privacy_socials = ''matches'',
                                 u.privacy_sexuality = ''everyone'',
                                 u.privacy_country = ''everyone'',
                                 u.privacy_kinks = ''everyone'',
                                 u.weight_custom_interests = 5, u.weight_default_interests = 3,
                                 u.weight_games = 3, u.weight_country = 3, u.weight_monopoly = 5,
                                 u.weight_personality = 0.5, u.weight_domsub = 5,
                                 u.weight_kinks = 3,
                                 u.optout = false,
                                 u.nsfw = false,
                                 u.volume = 0.5,
                                 u.registered = '''`{date -ui}^'''
                   MERGE (c:confirm {id: '''$confirm''', expiry: '`{+ $dateun 86400}^'})
                   MERGE (u)-[:CONFIRM]->(c)'

# Email confirmation
sed 's/\$confirm/'$confirm'/' < mail/confirm | email $p_username 'Please confirm your email'

login_user $p_username $p_password
