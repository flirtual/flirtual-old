title = 'Report Profile'

require_login

if {!~ $REQUEST_METHOD POST} { return 0 }

if {isempty $p_id} { return 0 }

# Validate ID
if {! echo $p_id | grep -s '^[a-zA-Z0-9_\-]+$' ||
    !~ `{redis graph read 'MATCH (u:user {id: '''$p_id'''}) RETURN exists(u)'} true} {
    throw error 'Invalid user'
}

# Create report, temp shadowban if >1 unreviewed
redis graph write 'MATCH (u:user {id: '''$p_id'''}),
                         (lu:user {username: '''$logged_user'''})
                   MERGE (lu)-[:REPORTED {reviewed: false}]->(u)'
shadowbanned = `{redis graph write 'MATCH (r:user)
                                          -[:REPORTED {reviewed: false}]->
                                          (u:user {id: '''$p_id'''})
                                    WITH u, count(r) AS c
                                    WHERE c > 1
                                    SET u.shadowbanned = true
                                    RETURN u.shadowbanned'}

p_details = `{echo $p_details | tr $NEWLINE ' '}
if {isempty $p_details} {
    p_details = 'None'
}

if {!~ $^p_reason 'Spam or troll account' &&
    !~ $^p_reason 'Hateful content' &&
    !~ $^p_reason 'Violent or disturbing content' &&
    !~ $^p_reason 'Nude or NSFW pictures' &&
    !~ $^p_reason 'Harassment' &&
    !~ $^p_reason 'Impersonating me or someone else' &&
    !~ $^p_reason 'Scam, malware, or harmful links' &&
    !~ $^p_reason 'Advertising' &&
    !~ $^p_reason 'Underage user' &&
    !~ $^p_reason 'Illegal content' &&
    !~ $^p_reason 'Self-harm content'} {
    p_reason = 'Other'
}

username = `{redis graph read 'MATCH (u:user {id: '''$p_id'''})
                               RETURN u.username'}
avatar = `{redis graph read 'MATCH (u:user {id: '''$p_id'''})
                                   -[:AVATAR]->
                                   (a:avatar {order: 0})
                             RETURN a.url' | sed 's/\/.*//'}
if {isempty $avatar} {
    avatar = 'e8212f93-af6f-4a2c-ac11-cb328bbc4aa4'
}

# Discord webhook
curl -H 'Content-Type: application/json' \
     -d '{
             "embeds": [{
                 "author": {
                     "name": "'$username'",
                     "url": "https://flirtu.al/'$username'",
                     "icon_url": "https://media.flirtu.al/'$avatar'/-/scale_crop/32x32/smart_faces_points/-/format/auto/-/quality/smart/"
                 },
                 "title": "New report",
                 "fields": [{
                     "name": "Reporter",
                     "value": "'$logged_user'"
                 }, {
                     "name": "Reason",
                     "value": "'$^p_reason'"
                 }, {
                     "name": "Details",
                     "value": "'$^p_details'"
                 '`^{if {~ $shadowbanned true} { echo '}, {
                     "name": "User has been shadowbanned! ⚠️",
                     "value": "This user has received multiple reports, so they''ve been removed from matchmaking. Please clear reports to unban if appropriate."'}}^'
                 }],
                 "color": 15295883
             }]
         }' \
     $DISCORD_WEBHOOK
