require_login

redis graph write 'MATCH (a:user)-[r:WAVED]->(b:user {username: '''$logged_user'''})
                   SET r.email = NULL'
