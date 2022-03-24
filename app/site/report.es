require_login

if {!~ $REQUEST_METHOD POST} { return 0 }

if {isempty $p_id} { return 0 }

# Validate ID
if {! echo $p_id | grep -s '^'$allowed_user_chars'+$' ||
    !~ `{redis graph read 'MATCH (u:user {username: '''$p_id'''}) RETURN exists(u)'} true} {
    throw error 'Invalid user'
}

p_details = `{echo $p_details | tr $NEWLINE ' '}
if {isempty $p_details} {
    p_details = 'None'
}

avatar = `{redis graph read 'MATCH (u:user {username: '''$p_id'''})
                                   -[:AVATAR]->
                                   (a:avatar {order: 0})
                             RETURN a.url' | sed 's/\/.*//'}
if {isempty $avatar} {
    avatar = 'e8212f93-af6f-4a2c-ac11-cb328bbc4aa4'
}

# Email
sed 's/\$id/'$p_id'/; s/\$details/'$^p_details'/' < mail/report | email mod 'New report'

# Discord webhook
curl -H 'Content-Type: application/json' \
     -d '{
             "embeds": [{
                 "author": {
                     "name": "'$p_id'",
                     "url": "https://flirtu.al/'$p_id'",
                     "icon_url": "https://media.flirtu.al/'$avatar'/-/scale_crop/32x32/smart_faces_points/-/format/auto/-/quality/smart/"
                 },
                 "title": "New report",
                 "fields": [{
                     "name": "Details",
                     "value": "'$^p_details'"
                 }],
                 "color": 15295883
             }]
         }' \
     $DISCORD_WEBHOOK
