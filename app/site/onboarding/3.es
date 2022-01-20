require_login
if {! isempty $onboarding && !~ $onboarding 3} {
    post_redirect /
}

if {!~ $REQUEST_METHOD POST} { return 0 }

# Back button -> return to previous onboarding page
if {~ $p_back true} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''}) SET u.onboarding = 2'
    post_redirect /onboarding/2
}

# Set display name, or if none is chosen, copy username
# This makes our life easier later
if {!isempty $p_displayname} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       SET u.displayname = '''$^p_displayname''''
    xmpp set_vcard '{"user": "'$logged_user'", "host": "'$XMPP_HOST'", "name": "FN", "content": "'$^p_displayname'"}'
} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       SET u.displayname = '''$logged_user''''
    xmpp set_vcard '{"user": "'$logged_user'", "host": "'$XMPP_HOST'", "name": "FN", "content": "'$logged_user'"}'
}

# Validate and set date of birth
if {! isempty $p_dob} {
    if {!~ $^p_dob [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] ||
    ~ `{echo $p_dob | sed 's/^.*-(.*)-.*$/\1/' | awk '{ print ($1 >= 1 && $1 <= 12) }'} 0 ||
    ~ `{echo $p_dob | sed 's/^.*-.*-(.*)$/\1/' | awk '{ print ($1 >= 1 && $1 <= 31) }'} 0} {
        throw error 'Invalid date of birth'
    }
    if {gt `{echo $p_dob | tr -d '-'} `{- `{yyyymmdd `{date -u | sed 's/  / 0/'}} 180000}} {
        throw error 'You must be at least 18 years of age to use this website'
    }
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       SET u.dob = '''$p_dob''''
} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       SET u.dob = NULL'
}

# Set gender
if {!~ $p_gender Man && !~ $p_gender Woman && ! isempty $p_gender_other} {
    p_gender = $p_gender_other
}
if {! isempty $p_gender} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       SET u.gender = '''`^{echo $p_gender | escape_redis}^''''
} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       SET u.gender = NULL'
}

# Validate and set country
if {! isempty $p_country} {
    if {!~ `{redis graph read 'MATCH (c:country {id: '''$p_country'''}) RETURN exists(c)'} true} {
        throw error 'Invalid country'
    }
    redis graph write 'MATCH (u:user {username: '''$logged_user'''}),
                             (c:country {id: '''$p_country'''})
                       CREATE (u)-[:COUNTRY]->(c)'
} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})-[r:COUNTRY]->(c:country)
                       DELETE r'
}

# Validate and write language
redis graph write 'MATCH (u:user {username: '''$logged_user'''})-[e:KNOWS]->(l:language) DELETE e'
languageset = false
languages = `^{redis graph read 'MATCH (l:language) RETURN l.id'}
for (language = `{echo $^p_language | sed 's/ /_/g; s/,/ /g'}) {
    if {in $language $languages} {
        languageset = true
        redis graph write 'MATCH (u:user {username: '''$logged_user'''}),
                                 (l:language {id: '''$language'''})
                           CREATE (u)-[:KNOWS]->(l)'
    }
}
if {~ $languageset false} {
    throw error 'Missing language'
}

# Validate and write platforms
redis graph write 'MATCH (u:user {username: '''$logged_user'''})-[e:USES]->(p:platform) DELETE e'
platformset = false
for (platform = `{redis graph read 'MATCH (p:platform) RETURN p.name'}) {
    if {~ $(p_$platform) true} {
        platformset = true
        redis graph write 'MATCH (u:user {username: '''$logged_user'''}),
                                 (p:platform {name: '''$platform'''})
                           CREATE (u)-[:USES]->(p)'
    }
}
if {~ $platformset false} {
    throw error 'Missing VR platform'
}

# Proceed
if {! isempty $onboarding} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       SET u.onboarding = 4'
    post_redirect /onboarding/4
} {
    post_redirect '/settings#edit'
}
