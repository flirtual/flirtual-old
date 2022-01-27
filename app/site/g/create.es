require_login

if {!~ $REQUEST_METHOD POST} { return 0 }

# Validation
if {isempty $p_name} {
    throw error 'Missing group name'
}
if {isempty $p_url || ! echo $p_url | grep -s '^'$allowed_user_chars'+$'} {
    throw error 'Invalid group URL. Allowed characters: [<pre>a-z, A-Z, 0-9, _</pre>]'
}
if {~ `{redis graph read 'MATCH (g:group {url: '''`^{echo $p_url | tr 'A-Z' 'a-z'}^'''})
                          RETURN exists(g)'} true || test -e g/$p_url || test -e g/$p_url.*} {
    throw error 'A group already exists with this URL. Please choose another'
}
if {isempty $p_description || ~ $p_description '<p><br></p>'} {
    throw error 'Missing group description'
}
if {!~ $p_type public && !~ $p_type private} {
    throw error 'Invalid group type'
}

# Create group
redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                   MERGE (g:group {name: '''`^{echo $^p_name | escape_redis}^''',
                                   url: '''$p_url''',
                                   description: '''`^{echo $p_description |
                                                      sed 's/\\//g' | bluemonday |
                                                      sed 's/<a /<a onclick="external_link(event, this)" /g' |
                                                      escape_redis}^''',
                                   type: '''$p_type''',
                                   invite: '''`^{kryptgo genid}^'''})
                   MERGE (u)-[:ADMINS]->(g)
                   MERGE (u)-[:MEMBER]->(g)'

# Validate and write interests
defaultset = false
interests_default = `^{redis graph read 'MATCH (t:tag) WHERE t.category <> ''custom'' RETURN t.name'}
for (tag = `{echo $^p_interests_default | sed 's/ /_/g; s/,/ /g'}) {
    if {in $tag $interests_default} {
        defaultset = true
        redis graph write 'MATCH (g:group {url: '''$p_url'''}),
                                 (t:tag {name: '''$tag'''})
                           WHERE t.category <> ''custom''
                           MERGE (g)-[:TAGGED]->(t)'
    }
}
if {~ $defaultset false} {
    redis graph write 'MATCH (g:group {url: '''$p_url'''}) DELETE g'
    throw error 'Missing or invalid tags'
}
for (tag = `{echo $^p_interests_custom | sed 's/ /_/g; s/,/ /g' | escape_redis}) {
    existingtag = `{redis graph read 'MATCH (t:tag {category: ''custom''})
                                      WHERE toLower(t.name) = '''`^{echo $tag | tr 'A-Z' 'a-z'}^'''
                                      RETURN t.name'}
    if {isempty $existingtag} {
        # Create new tag
        redis graph write 'MATCH (g:group {url: '''$p_url'''})
                           MERGE (t:tag {name: '''$tag''', category: ''custom''})
                           MERGE (g)-[:TAGGED]->(t)'
    } {
        # Existing tag; link to group
        redis graph write 'MATCH (g:group {url: '''$p_url'''}),
                                 (t:tag {name: '''$existingtag''', category: ''custom''})
                           MERGE (g)-[:TAGGED]->(t)'
    }
}

# Validate and write Discord invite
if {! isempty $p_discord} {
    p_discord = `{echo $p_discord |
                  sed 's/^(https?:\/\/)?(www\.)?discord(app)?\.(gg|com)(\/invite)?\///'}

    if {echo $p_discord | grep -s '^[a-zA-Z0-9]*$'} {
        redis graph write 'MATCH (g:group {url: '''$p_url'''})
                           SET g.discord = '''$p_discord''''
    }
}

# Proceed
post_redirect /g/$p_url
