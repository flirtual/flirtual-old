require_login

if {!~ `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})
                           RETURN exists(u.premium)'} true} {
    post_redirect /
}

if {!~ $REQUEST_METHOD POST} { return 0 }

# Clean up old undone profiles
redis graph write 'MATCH (a:user {username: '''$logged_user'''})-[u:UNDO]->(b:user)
                   DELETE u'

# Get the last user liked (non-match) or passed on
(lastlike lastlike_date) = `{redis graph read 'MATCH (a:user {username: '''$logged_user'''})
                                                     -[l:LIKED]->(b:user)
                                               WHERE NOT (b)-[:LIKED]->(a)
                                               RETURN b.username, l.date
                                               ORDER BY l.date DESC
                                               LIMIT 1'}

(lastpass lastpass_date) = `{redis graph read 'MATCH (a:user {username: '''$logged_user'''})
                                                     -[p:PASSED]->(b:user)
                                               RETURN b.username, p.date
                                               ORDER BY p.date DESC
                                               LIMIT 1'}

# Remove the like/pass and get ready to render their profile in undo.tpl
if {gt $lastlike_date $lastpass_date} {
    redis graph write 'MATCH (a:user {username: '''$logged_user'''})
                             -[l:LIKED]->
                             (b:user {username: '''$lastlike'''})
                       DELETE l'
    redis graph write 'MATCH (a:user {username: '''$logged_user'''}),
                             (b:user {username: '''$lastlike'''})
                       MERGE (a)-[:UNDO]->(b)'
} {
    redis graph write 'MATCH (a:user {username: '''$logged_user'''})
                             -[p:PASSED]->
                             (b:user {username: '''$lastpass'''})
                       DELETE p'
    redis graph write 'MATCH (a:user {username: '''$logged_user'''}),
                             (b:user {username: '''$lastpass'''})
                       MERGE (a)-[:UNDO]->(b)'
}
