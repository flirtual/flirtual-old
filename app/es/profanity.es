fn profanity {
    flags = `^{echo $^* | tr 'A-Z' 'a-z' | /bin/grep -o $PROFANITY}

    if {! isempty $flags} {
        avatar = `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})
                                           -[:AVATAR]->
                                           (a:avatar {order: 0})
                                     RETURN a.url' | sed 's/\/.*//'}
        if {isempty $avatar} {
            avatar = 'e8212f93-af6f-4a2c-ac11-cb328bbc4aa4'
        }

        curl -s -H 'Content-Type: application/json' \
             -d '{
                     "embeds": [{
                         "author": {
                             "name": "'$logged_user'",
                             "url": "https://flirtu.al/'$logged_user'",
                             "icon_url": "https://media.flirtu.al/'$avatar'/-/scale_crop/32x32/smart_faces_points/-/format/auto/-/quality/smart/"
                         },
                         "title": "Profile auto-flagged",
                         "fields": [{
                             "name": "Flags",
                             "value": "'$^flags'"
                         }],
                         "color": 15295883
                     }]
                 }' \
             $DISCORD_WEBHOOK
    }
}
