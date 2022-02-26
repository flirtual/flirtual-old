# Missing confirmation ID -> bye
if {isempty $q_id} { return 0 }

expiry = `{redis graph read 'MATCH (u:user)-[:CONFIRM]->(c:confirm {id: '''`^{echo $q_id | escape_redis}^'''})
                             RETURN c.expiry'}

if {isempty $expiry} {
    throw error 'Your confirmation link is invalid. Please try again'
} {lt $expiry $dateun} {
    # Confirmation expired; generate a new ID
    confirm = `{kryptgo genid}

    # Email it
    u = `{redis graph read 'MATCH (u:user)-[:CONFIRM]->(c:confirm {id: '''`^{echo $q_id | escape_redis}^'''})
                            RETURN u.username'}
    sed 's/\$confirm/'$confirm'/' < mail/confirm | email $u 'Please confirm your email'

    # Create confirmation with expiry in 24 hours
    redis graph write 'MATCH (u:user {username: '''$u'''})
                       MERGE (c:confirm {id: '''$confirm''', expiry: '`{+ $dateun 86400}^'})
                       MERGE (u)-[:CONFIRM]->(c)'

    throw error 'Your confirmation link has expired. We''ve sent you a new one. Please check your email and confirm again'
}

user = `{redis graph read 'MATCH (u:user)-[:CONFIRM]->(c:confirm {id: '''`^{echo $q_id | escape_redis}^'''})
                           RETURN u.username'}

# Clean up old confirmation
redis graph write 'MATCH (u:user)-[:CONFIRM]->(c:confirm {id: '''`^{echo $q_id | escape_redis}^'''})
                   SET u.confirmed = true
                   DELETE c'

# Start matchmaking if onboarding is finished
onboarding = `{redis graph read 'MATCH (u:user {username: '''$user'''})
                                 RETURN u.onboarding'}
if {isempty $onboarding || ~ $onboarding 5} {
    redis graph write 'MATCH (u:user {username: '''$user'''})
                       SET u.recompute_matches = true, u.initial_matches = true,
                           u.onboarding = NULL'
}

confirm_success = true
