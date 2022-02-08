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

# Relationship type
redis graph write 'MATCH (u:user {username: '''$logged_user'''})-[l:LF]->(r:relationship)
                   DELETE l'
relationshipset = false
if {~ $p_Homies true} {
    relationshipset = true
    redis graph write 'MATCH (u:user {username: '''$logged_user'''}),
                             (r:relationship {name: ''Homies''})
                       MERGE (u)-[:LF]->(r)'
}
if {~ $p_Casual_dating true} {
    relationshipset = true
    redis graph write 'MATCH (u:user {username: '''$logged_user'''}),
                             (r:relationship {name: ''Casual_dating''})
                       MERGE (u)-[:LF]->(r)'
}
if {~ $p_Serious_dating true} {
    relationshipset = true
    redis graph write 'MATCH (u:user {username: '''$logged_user'''}),
                             (r:relationship {name: ''Serious_dating''})
                       MERGE (u)-[:LF]->(r)'
}
if {~ $p_Hookups true} {
    relationshipset = true
    redis graph write 'MATCH (u:user {username: '''$logged_user'''}),
                             (r:relationship {name: ''Hookups''})
                       MERGE (u)-[:LF]->(r)'
}
if {~ $relationshipset false} {
    throw error 'Missing relationship type'
}

# (Non-)Monogamous
if {~ $p_monopoly Monogamous || ~ $p_monopoly Non-monogamous} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       SET u.monopoly = '''$p_monopoly''''
} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       SET u.monopoly = NULL'
}

# Gender preference
redis graph write 'MATCH (u:user {username: '''$logged_user'''})-[l:LF]->(g:gender)
                   DELETE l'
genderset = false
if {~ $p_Women true} {
    genderset = true
    redis graph write 'MATCH (u:user {username: '''$logged_user'''}),
                             (g:gender {name: ''Woman''})
                       MERGE (u)-[:LF]->(g)'
}
if {~ $p_Men true} {
    genderset = true
    redis graph write 'MATCH (u:user {username: '''$logged_user'''}),
                             (g:gender {name: ''Man''})
                       MERGE (u)-[:LF]->(g)'
}
if {~ $p_Other true} {
    genderset = true
    redis graph write 'MATCH (u:user {username: '''$logged_user'''}),
                             (g:gender {type: ''nonbinary''})
                       MERGE (u)-[:LF]->(g)'
}
if {~ $genderset false} {
    throw error 'Missing gender preference'
}

# Proceed
if {! isempty $onboarding} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       SET u.onboarding = 3'
    post_redirect /onboarding/3
} {
    post_redirect '/settings#edit'
}
