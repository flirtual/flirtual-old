title = 'Reset Password'

# Missing reset ID -> bye
if {isempty $q_id} { return 0 }

# Check reset expiry
expiry = `{redis graph read 'MATCH (u:user)-[:RESET]->(r:reset {id: '''`^{echo $q_id | escape_redis}^'''})
                             RETURN r.expiry'}
if {isempty $expiry} {
    throw error 'Your password reset link is invalid. Please try again'
} {lt $expiry $dateun} {
    throw error 'Your password reset link has expired. Please try again'
}

if {!~ $REQUEST_METHOD POST} { return 0 }

# Check if provided user matches provided reset
username = `{echo $p_username | tr 'A-Z' 'a-z' | escape_redis}
if {!~ `{redis graph read 'MATCH (u:user), (r:reset)
                           WHERE (u)-[:RESET]->(r) AND
                                 (toLower(u.username) = '''$username''' OR
                                 toLower(u.email) = '''$username''') AND
                                 r.id = '''$q_id'''
                           RETURN exists(u)'} true} {
    throw error 'Wrong username/email'
}

# Validate password
if {isempty $p_password ||
    le `{echo $p_password | wc -c} 8} {
    throw error 'Your password must be at least 8 characters long'
}

# Update password and clean up old reset
redis graph write 'MATCH (u:user)-[:RESET]->(r:reset {id: '''$q_id'''})
                   SET u.password = '''`{kryptgo genhash -p $p_password}^'''
                   DELETE r'

reset_success = true
