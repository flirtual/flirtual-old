require_login
if {!~ $onboarding 5} {
    post_redirect /
}

# Email confirmed? Proceed
if {~ `{redis graph read 'MATCH (u:user {username: '''$logged_user'''}) RETURN u.confirmed'} true} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''}) SET u.onboarding = NULL'
    post_redirect /
}

if {!~ $REQUEST_METHOD POST} { return 0 }

if {~ $p_resend yes} {
    # Resend confirmation email
    # Generate new confirm ID
    confirm = `{kryptgo genid}

    # Email it
    sed 's/\$confirm/'$confirm'/' < mail/confirm | email $logged_user 'Please confirm your email'

    # Create confirmation with expiry in 24 hours
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       MERGE (c:confirm {id: '''$confirm''', expiry: '`{+ $dateun 86400}^'})
                       MERGE (u)-[:CONFIRM]->(c)'
} {! isempty $p_email} {
    # Change email
    # Format email, check availability
    p_email = `{echo $p_email | tr 'A-Z' 'a-z' | escape_redis}
    if {~ `{redis graph read 'MATCH (u:user {email: '''$p_email'''}) RETURN exists(u)'} true} {
        throw error 'An account already exists with this email address'
    }

    # Generate new confirm ID
    confirm = `{kryptgo genid}

    # Update email and create confirmation with expiry in 24 hours
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       SET u.email = '''$p_email'''
                       MERGE (c:confirm {id: '''$confirm''', expiry: '`{+ $dateun 86400}^'})
                       MERGE (u)-[:CONFIRM]->(c)'

    # Email confirmation
    sed 's/\$confirm/'$confirm'/' < mail/confirm | email $logged_user 'Please confirm your email'

    update_success = true
}
