require_login
if {! isempty $onboarding && !~ $onboarding 1} {
    post_redirect /
}

if {!~ $REQUEST_METHOD POST} { return 0 }

# Gender preference
redis graph write 'MATCH (u:user {username: '''$logged_user'''})-[l:LF]->(g:gender)
                   DELETE l'
genderset = false
if {~ $p_Women true} {
    genderset = true
    redis graph write 'MATCH (u:user {username: '''$logged_user'''}),
                             (g:gender {name: ''Woman''}),
                             (gp:gender {name: ''She/Her''})
                       MERGE (u)-[:LF]->(g)
                       MERGE (u)-[:LF]->(gp)'
}
if {~ $p_Men true} {
    genderset = true
    redis graph write 'MATCH (u:user {username: '''$logged_user'''}),
                             (g:gender {name: ''Man''}),
                             (gp:gender {name: ''He/Him''})
                       MERGE (u)-[:LF]->(g)
                       MERGE (u)-[:LF]->(gp)'
}
if {~ $p_Other true} {
    genderset = true
    redis graph write 'MATCH (u:user {username: '''$logged_user'''}),
                             (g:gender {type: ''nonbinary''})
                       WHERE g.name <> ''She/Her'' AND
                             g.name <> ''He/Him''
                       MERGE (u)-[:LF]->(g)'
}
if {~ $genderset false} {
    throw error 'Missing gender preference'
}

# Age range preference
if {! isempty $p_agemin && ge $p_agemin 18 && le $p_agemin 125} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       SET u.agemin = '$p_agemin
} {
    throw error 'Missing/invalid age range'
}
if {! isempty $p_agemax && ge $p_agemax 18 && le $p_agemax 125} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       SET u.agemax = '$p_agemax
} {
    throw error 'Missing/invalid age range'
}

# Open to serious dating?
if {~ $p_serious true} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       SET u.serious = true'
} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       SET u.serious = false'
}

# (Non-)Monogamous
if {~ $p_monopoly Monogamous || ~ $p_monopoly Non-monogamous} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       SET u.monopoly = '''$p_monopoly''''
} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       SET u.monopoly = NULL'
}

# Proceed
if {! isempty $onboarding} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       SET u.onboarding = 2'
    post_redirect /onboarding/2
} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       SET u.recompute_matches = true'
    post_redirect '/settings#edit'
}
