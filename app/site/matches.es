require_login

if {!~ $REQUEST_METHOD POST} { return 0 }

if {~ $p_reset likes} {
    redis graph write 'MATCH (a:user {username: '''$logged_user'''})
                             -[l:LIKED]->(b:user)
                       WHERE NOT (a)-[:MATCHED]-(b)
                       DELETE l'
    success = 'Likes/homies'
} {~ $p_reset passes} {
    redis graph write 'MATCH (a:user {username: '''$logged_user'''})
                             -[p:PASSED]->(b:user)
                       DELETE p'
    redis graph write 'MATCH (a:user {username: '''$logged_user'''})
                             -[p:HPASSED]->(b:user)
                       DELETE p'
    success = 'Passes'
}