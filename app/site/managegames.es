if {!~ `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})
                           RETURN u.admin'} true} {
    post_redirect /login
}

if {!~ $REQUEST_METHOD POST} { return 0 }

p_name = `{echo $^p_name | sed 's/''//g; s/ /_/g'}

# Create game if it doesn't already exist
if {!~ `{redis graph read 'MATCH (g:game {name: '''$^p_name'''}) RETURN exists(g)'} true} {
    redis graph write 'MERGE (g:game {name: '''$p_name'''})'
}

# Set type
redis graph write 'MATCH (g:game {name: '''$p_name'''}) SET g.type = '''$p_type''''

# Remove existing connections
redis graph write 'MATCH (g:game {name: '''$p_name'''})-[e:TAGGED]->(t:tag) DELETE e'
redis graph write 'MATCH (g:game {name: '''$p_name'''})-[e:SUPPORTS]->(p:platform) DELETE e'

# Validate non-custom tags
tags_social = ()
for (tag = `{redis graph read 'MATCH (t:tag {category: ''social''}) RETURN t.name'}) {
    if {~ $(p_$tag) yes } {
        tags_social = ($tags_social $tag)
    }
}

tags_gaming = ()
for (tag = `{redis graph read 'MATCH (t:tag {category: ''gaming''}) RETURN t.name'}) {
    if {~ $(p_$tag) yes } {
        tags_gaming = ($tags_gaming $tag)
    }
}

tags_genre = ()
for (tag = `{redis graph read 'MATCH (t:tag {category: ''genre''}) RETURN t.name'}) {
    if {~ $(p_$tag) yes } {
        tags_genre = ($tags_genre $tag)
    }
}

tags_life = ()
for (tag = `{redis graph read 'MATCH (t:tag {category: ''life''}) RETURN t.name'}) {
    if {~ $(p_$tag) yes } {
        tags_life = ($tags_life $tag)
    }
}

tags_creation = ()
for (tag = `{redis graph read 'MATCH (t:tag {category: ''creation''}) RETURN t.name'}) {
    if {~ $(p_$tag) yes } {
        tags_creation = ($tags_creation $tag)
    }
}

# Write tags
for (category = social gaming genre life creation) {
    for (tag = $(tags_$category)) {
        redis graph write 'MATCH (g:game {name: '''$p_name'''}),
                                 (t:tag {name: '''$tag''', category: '''$category'''})
                           MERGE (g)-[:TAGGED]->(t)'
    }
}

# Validate and write platforms
for (platform = `{redis graph read 'MATCH (p:platform) RETURN p.name'}) {
    if {~ $(p_$platform) true} {
        redis graph write 'MATCH (g:game {name: '''$p_name'''}),
                                 (p:platform {name: '''$platform'''})
                           MERGE (g)-[:SUPPORTS]->(p)'
    }
}
