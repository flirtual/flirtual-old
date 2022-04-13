if {~ $p_return /homies} {
    title = 'Homie Mode'
} {
    title = 'Browsing'
}

require_login

if {!~ $REQUEST_METHOD POST} { return 0 }

# Direct profile (not browsing)
if {! isempty $p_user} {
    # Validate user
    p_user = `{echo $p_user | grep '^[a-zA-Z0-9_\-]+$'}
    (p_user id) = `` \n {redis graph read 'MATCH (u:user)
                                           WHERE u.username = '''$p_user''' OR
                                                 u.id = '''$p_user'''
                                           RETURN u.username, u.id'}
    if {isempty $p_user} {
        post_redirect /
    }

    # Unlike/unpass
    redis graph write 'MATCH (a:user {username: '''$logged_user'''})
                             -[l:LIKED]->
                             (b:user {username: '''$p_user'''})
                       DELETE l'
    redis graph write 'MATCH (a:user {username: '''$logged_user'''})
                             -[p:PASSED]->
                             (b:user {username: '''$p_user'''})
                       DELETE p'
    post_redirect /$id
}

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

(lasthpass lasthpass_date) = `{redis graph read 'MATCH (a:user {username: '''$logged_user'''})
                                                       -[p:HPASSED]->(b:user)
                                                 RETURN b.username, p.date
                                                 ORDER BY p.date DESC
                                                 LIMIT 1'}

# Remove the like/pass and get ready to render their profile in undo.tpl
if {gt $lastlike_date $lastpass_date && gt $lastlike_date $lasthpass_date} {
    redis graph write 'MATCH (a:user {username: '''$logged_user'''})
                             -[l:LIKED]->
                             (b:user {username: '''$lastlike'''})
                       DELETE l'
    redis graph write 'MATCH (a:user {username: '''$logged_user'''}),
                             (b:user {username: '''$lastlike'''})
                       MERGE (a)-[:UNDO]->(b)'
} {gt $lastpass_date $lasthpass_date} {
    redis graph write 'MATCH (a:user {username: '''$logged_user'''})
                             -[p:PASSED]->
                             (b:user {username: '''$lastpass'''})
                       DELETE p'
    redis graph write 'MATCH (a:user {username: '''$logged_user'''}),
                             (b:user {username: '''$lastpass'''})
                       MERGE (a)-[:UNDO]->(b)'
} {
    redis graph write 'MATCH (a:user {username: '''$logged_user'''})
                             -[p:HPASSED]->
                             (b:user {username: '''$lasthpass'''})
                       DELETE p'
    redis graph write 'MATCH (a:user {username: '''$logged_user'''}),
                             (b:user {username: '''$lasthpass'''})
                       MERGE (a)-[:UNDO]->(b)'
}
