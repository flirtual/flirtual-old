title = 'Forgot Password'

if {!~ $REQUEST_METHOD POST} { return 0 }

# Did they give us their email?
if {isempty $p_email} {
    throw error 'Missing email'
}

# Does the email belong to an account?
username = `{redis graph write 'MATCH (u:user)
                                WHERE toLower(u.email) = '''`^{echo $p_email | tr 'A-Z' 'a-z' | escape_redis}^'''
                                RETURN u.username'}
if {isempty $username} {
    throw error 'No account exists with that email address'
}

# Generate a reset ID
reset = `{kryptgo genid}

# Email it
sed 's/\$reset/'$reset'/' < mail/reset | email $username 'Password reset request'

# Create reset
redis graph write 'MATCH (u:user {username: '''$username'''})
                   MERGE (r:reset {id: '''$reset''', expiry: '`{+ $dateun 86400}^'})
                   MERGE (u)-[:RESET]->(r)'

forgot_success = true
