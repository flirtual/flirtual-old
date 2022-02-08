require_login
if {! isempty $onboarding && !~ $onboarding 1} {
    post_redirect /
}

if {!~ $REQUEST_METHOD POST} { return 0 }

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
redis graph write 'MATCH (u:user {username: '''$logged_user'''})-[r:GENDER]->(g:gender) DELETE r'
genderset = false
if {~ $p_gender_woman true} {
    genderset = true
    redis graph write 'MATCH (u:user {username: '''$logged_user'''}),
                             (g:gender {name: ''Woman''})
                       MERGE (u)-[:GENDER]->(g)'
}
if {~ $p_gender_man true} {
    genderset = true
    redis graph write 'MATCH (u:user {username: '''$logged_user'''}),
                             (g:gender {name: ''Man''})
                       MERGE (u)-[:GENDER]->(g)'
}
if {~ $p_gender_other true} {
    genders = `^{redis graph read 'MATCH (g:gender {type: ''nonbinary''}) RETURN g.name'}
    for (gender = `{echo $^p_genders_other | sed 's/ /_/g; s/,/ /g'}) {
        if {in $gender $genders} {
            genderset = true
            redis graph write 'MATCH (u:user {username: '''$logged_user'''}),
                                     (g:gender {name: '''$gender'''})
                               MERGE (u)-[:GENDER]->(g)'
        }
    }
}
if {~ $genderset false} {
    throw error 'Missing gender'
}

# Validate and set sexuality
redis graph write 'MATCH (u:user {username: '''$logged_user'''})-[r:SEXUALITY]->(s:sexuality) DELETE r'
sexualities = `^{redis graph read 'MATCH (s:sexuality) RETURN s.name'}
for (sexuality = `{echo $^p_sexuality | sed 's/ /_/g; s/,/ /g'}) {
    if {in $sexuality $sexualities} {
        redis graph write 'MATCH (u:user {username: '''$logged_user'''}),
                                 (s:sexuality {name: '''$sexuality'''})
                           MERGE (u)-[:SEXUALITY]->(s)'
    }
}

# Validate and set privacy setting
if {!~ $p_privacy vrlfp && !~ $p_privacy friends && !~ $p_privacy me} {
    throw error 'Invalid privacy setting'
} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       SET u.privacy_sexuality = '''$p_privacy''''
}

# Validate and set country
if {! isempty $p_country} {
    if {!~ `{redis graph read 'MATCH (c:country {id: '''$p_country'''}) RETURN exists(c)'} true} {
        throw error 'Invalid country'
    }
    redis graph write 'MATCH (u:user {username: '''$logged_user'''}),
                             (c:country {id: '''$p_country'''})
                       MERGE (u)-[:COUNTRY]->(c)'
} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})-[r:COUNTRY]->(c:country)
                       DELETE r'
}

# Validate and write language
redis graph write 'MATCH (u:user {username: '''$logged_user'''})-[r:KNOWS]->(l:language) DELETE r'
languageset = false
languages = `^{redis graph read 'MATCH (l:language) RETURN l.id'}
for (language = `{echo $^p_language | sed 's/,/ /g'}) {
    if {in $language $languages} {
        languageset = true
        redis graph write 'MATCH (u:user {username: '''$logged_user'''}),
                                 (l:language {id: '''$language'''})
                           MERGE (u)-[:KNOWS]->(l)'
    }
}
if {~ $languageset false} {
    throw error 'Missing language'
}

# Validate and write platforms
redis graph write 'MATCH (u:user {username: '''$logged_user'''})-[r:USES]->(p:platform) DELETE r'
platformset = false
for (platform = `{redis graph read 'MATCH (p:platform) RETURN p.name'}) {
    if {~ $(p_$platform) true} {
        platformset = true
        redis graph write 'MATCH (u:user {username: '''$logged_user'''}),
                                 (p:platform {name: '''$platform'''})
                           MERGE (u)-[:USES]->(p)'
    }
}
if {~ $platformset false} {
    throw error 'Missing VR platform'
}

# Proceed
if {! isempty $onboarding} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       SET u.onboarding = 2'
    post_redirect /onboarding/2
} {
    post_redirect '/settings#edit'
}
