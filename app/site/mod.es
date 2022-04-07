require_login

if {!~ $REQUEST_METHOD POST ||
    !~ `{redis graph read 'MATCH (u:user {username: '''$logged_user'''}) RETURN u.mod'} true} {
    return 0
}

# Validate users
if {! echo $p_user | grep -s '^'$allowed_user_chars'+$' ||
    !~ `{redis graph read 'MATCH (u:user {username: '''$p_user'''}) RETURN exists(u)'} true} {
    post_redirect /
}

if {~ $p_action ban} {
    if {isempty $p_reason} {
        throw error 'Missing reason'
    }
    redis graph write 'MATCH (u:user {username: '''$p_user'''})
                       SET u.banned = '$dateun
    redis graph write 'MATCH (a:user)-[m:DAILYMATCH]->(b:user {username: '''$p_user'''})
                       DELETE m'

    # Email
    reason = `{echo $p_reason | escape_html}
    email = 'moderation@flirtu.al'
    sed 's/\$reason/'$^reason'/' < mail/ban | email $p_user 'Your account has been disabled'

    # Discord webhook
    avatar = `{redis graph read 'MATCH (u:user {username: '''$p_user'''})
                                    -[:AVATAR]->
                                    (a:avatar {order: 0})
                                RETURN a.url' | sed 's/\/.*//'}
    if {isempty $avatar} {
        avatar = 'e8212f93-af6f-4a2c-ac11-cb328bbc4aa4'
    }
    curl -H 'Content-Type: application/json' \
        -d '{
                "embeds": [{
                    "author": {
                        "name": "'$p_user'",
                        "url": "https://flirtu.al/'$p_user'",
                        "icon_url": "https://media.flirtu.al/'$avatar'/-/scale_crop/32x32/smart_faces_points/-/format/auto/-/quality/smart/"
                    },
                    "title": "User banned",
                    "fields": [{
                        "name": "Moderator",
                        "value": "'$logged_user'"
                    }, {
                        "name": "Reason",
                        "value": "'$^reason'"
                    }],
                    "color": 15295883
                }]
            }' \
        $DISCORD_WEBHOOK
} {~ $p_action unban} {
    redis graph write 'MATCH (u:user {username: '''$p_user'''})
                       SET u.banned = NULL'
} {~ $p_action rmpfp} {
    if {isempty $p_avatar || ~ $p_avatar 'e8212f93-af6f-4a2c-ac11-cb328bbc4aa4'} {
        post_redirect /
    }

    redis graph write 'MATCH (a:avatar {url: '''$p_avatar'''}) DELETE a'

    # Discord webhook
    avatar = `{echo $p_avatar | sed 's/\/.*//'}
    dprint $avatar
    curl -H 'Content-Type: application/json' \
        -d '{
                "embeds": [{
                    "author": {
                        "name": "'$p_user'",
                        "url": "https://flirtu.al/'$p_user'",
                        "icon_url": "https://media.flirtu.al/'$avatar'/-/scale_crop/32x32/smart_faces_points/-/format/auto/-/quality/smart/"
                    },
                    "title": "Profile picture banned",
                    "fields": [{
                        "name": "Moderator",
                        "value": "'$logged_user'"
                    }],
                    "image": {
                        "url": "https://media.flirtu.al/'$avatar'/"
                    },
                    "color": 15295883
                }]
            }' \
        $DISCORD_WEBHOOK
} {~ $p_action verify && ~ `{redis graph read 'MATCH (u:user {username: '''$logged_user'''}) RETURN u.admin'} true} {
    if {~ `{redis graph read 'MATCH (u:user {username: '''$p_user'''})
                              RETURN exists(u.verified)'} false} {
        redis graph write 'MATCH (u:user {username: '''$p_user'''})
                           SET u.verified = true'
    } {
        redis graph write 'MATCH (u:user {username: '''$p_user'''})
                           SET u.verified = NULL'
    }
}

post_redirect /$p_user
