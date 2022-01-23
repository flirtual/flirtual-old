require_login
if {!~ $onboarding 6} {
    post_redirect /
}

if {!~ $REQUEST_METHOD POST} { return 0 }

# Back button -> return to previous onboarding page
if {~ $p_back true} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''}) SET u.onboarding = 5'
    post_redirect /onboarding/5
}

# Validate privacy settings
if {{!~ $p_age public && !~ $p_age vrlfp && !~ $p_age friends} ||
    {!~ $p_gender public && !~ $p_gender vrlfp && !~ $p_gender friends} ||
    {!~ $p_country public && !~ $p_country vrlfp && !~ $p_country friends} ||
    {!~ $p_interests_common vrlfp && !~ $p_interests_common friends} ||
    {!~ $p_interests_uncommon public && !~ $p_interests_uncommon vrlfp && !~ $p_interests_uncommon friends} ||
    {!~ $p_bio public && !~ $p_bio vrlfp && !~ $p_bio friends} ||
    {!~ $p_language public && !~ $p_language vrlfp && !~ $p_language friends} ||
    {!~ $p_platform public && !~ $p_platform vrlfp && !~ $p_platform friends} ||
    {!~ $p_games public && !~ $p_games vrlfp && !~ $p_games friends} ||
    {!~ $p_socials public && !~ $p_socials vrlfp && !~ $p_socials friends} ||
    {!~ $p_friends vrlfp && !~ $p_friends friends && !~ $p_friends hidden} ||
    {!~ $p_invite public && !~ $p_invite hidden} ||
    {!~ $p_optout true && !~ $p_optout false}} {
    throw error 'Invalid selection.'
}

# Write and proceed
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
                       u.optout = '$p_optout',
                       u.onboarding = 7'

post_redirect /onboarding/7
