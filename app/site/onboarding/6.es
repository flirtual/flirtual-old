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
if {{!~ $p_age public && !~ $p_age rovr && !~ $p_age friends} ||
    {!~ $p_gender public && !~ $p_gender rovr && !~ $p_gender friends} ||
    {!~ $p_country public && !~ $p_country rovr && !~ $p_country friends} ||
    {!~ $p_interests_common rovr && !~ $p_interests_common friends} ||
    {!~ $p_interests_uncommon public && !~ $p_interests_uncommon rovr && !~ $p_interests_uncommon friends} ||
    {!~ $p_bio public && !~ $p_bio rovr && !~ $p_bio friends} ||
    {!~ $p_language public && !~ $p_language rovr && !~ $p_language friends} ||
    {!~ $p_platform public && !~ $p_platform rovr && !~ $p_platform friends} ||
    {!~ $p_games public && !~ $p_games rovr && !~ $p_games friends} ||
    {!~ $p_socials public && !~ $p_socials rovr && !~ $p_socials friends} ||
    {!~ $p_friends rovr && !~ $p_friends friends && !~ $p_friends hidden} ||
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
