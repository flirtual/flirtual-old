require_login
if {! isempty $onboarding && !~ $onboarding 2} {
    post_redirect /
}

if {!~ $REQUEST_METHOD POST} { return 0 }

# Back button -> return to previous onboarding page
if {~ $p_back true} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''}) SET u.onboarding = 1'
    post_redirect /onboarding/1
}

# Validate and set date of birth
if {isempty $p_dob} {
    throw error 'Missing date of birth'
} {
    if {!~ $^p_dob [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] ||
        ~ `{echo $p_dob | sed 's/^.*-(.*)-.*$/\1/' | awk '{ print ($1 >= 1 && $1 <= 12) }'} 0 ||
        ~ `{echo $p_dob | sed 's/^.*-.*-(.*)$/\1/' | awk '{ print ($1 >= 1 && $1 <= 31) }'} 0 ||
        lt `{echo $p_dob | tr -d '-'} 19000101} {
        throw error 'Invalid date of birth'
    }
    dob = `{echo $p_dob | tr -d '-'}
    age = `{int `{/ `{- `{yyyymmdd `{date -u | sed 's/  / 0/'}} $dob} 10000}}
    if {lt $age 18} {
        throw error 'You must be at least 18 years of age to use this website'
    }
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       SET u.dob = '$dob
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

# Validate and set privacy settings
if {!~ $p_privacy_sexuality everyone && !~ $p_privacy_sexuality matches && !~ $p_privacy_sexuality me} {
    throw error 'Invalid privacy setting'
} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       SET u.privacy_sexuality = '''$p_privacy_sexuality''''
}
if {!~ $p_privacy_country everyone && !~ $p_privacy_country matches && !~ $p_privacy_country me} {
    throw error 'Invalid privacy setting'
} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       SET u.privacy_country = '''$p_privacy_country''''
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

# Validate and write platform
redis graph write 'MATCH (u:user {username: '''$logged_user'''})-[r:USES]->(p:platform) DELETE r'
platformset = false
platforms = `^{redis graph read 'MATCH (p:platform) RETURN p.name'}
for (platform = `{echo $^p_platform | sed 's/,/ /g'}) {
    if {in $platform $platforms} {
        platformset = true
        redis graph write 'MATCH (u:user {username: '''$logged_user'''}),
                                 (p:platform {name: '''$platform'''})
                           MERGE (u)-[:USES]->(p)'
    }
}
if {~ $platformset false} {
    throw error 'Missing VR setup'
}

# Check newness
if {!~ $^p_new true} {
    p_new = false
}

# Validate and write games
redis graph write 'MATCH (u:user {username: '''$logged_user'''})-[r:PLAYS]->(g:game) DELETE r'
games = `^{redis graph read 'MATCH (g:game) RETURN g.name'}
for (game = `{echo $^p_games | sed 's/ /_/g; s/,/ /g'}) {
    if {in $game $games} {
        redis graph write 'MATCH (u:user {username: '''$logged_user'''}),
                                 (g:game {name: '''$game'''})
                           MERGE (u)-[:PLAYS]->(g)'
    }
}

# Validate and write tags
redis graph write 'MATCH (u:user {username: '''$logged_user'''})-[r:TAGGED]->(i:interest) DELETE r'
tags = `^{redis graph read 'MATCH (i:interest) RETURN i.name'}
for (tag = `{echo $^p_interests | sed 's/ /_/g; s/,/ /g' | escape_redis}) {
    existingtag = `{redis graph read 'MATCH (i:interest)
                                      WHERE toLower(i.name) = '''`^{echo $tag | tr 'A-Z' 'a-z'}^'''
                                      RETURN i.name'}
    if {isempty $existingtag} {
        # Create new tag
        redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                           MERGE (i:interest {name: '''$tag''', type: ''custom''})
                           MERGE (u)-[:TAGGED]->(i)'
    } {
        # Existing tag; link to user
        redis graph write 'MATCH (u:user {username: '''$logged_user'''}),
                                 (i:interest {name: '''$existingtag'''})
                           MERGE (u)-[:TAGGED]->(i)'
    }
}

# Proceed
if {! isempty $onboarding} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       SET u.onboarding = 3'
    post_redirect /onboarding/3
} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       SET u.recompute_matches = true'
    post_redirect '/settings#edit'
}
