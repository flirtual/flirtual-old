require_login

if {!~ $REQUEST_METHOD POST} { return 0 }

# Set NSFW
if {~ $p_nsfw true} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       SET u.nsfw = true'
} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       SET u.nsfw = false'
}

# Validate and set dom/sub/switch
if {~ $p_domsub Dominant || ~ $p_domsub Submissive || ~ $p_domsub Switch} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       SET u.domsub = '''$p_domsub''''
} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       SET u.domsub = NULL'
}

# Validate and set kinks 
redis graph write 'MATCH (u:user {username: '''$logged_user'''})-[r:KINK]->(k:kink) DELETE r'
kinks = `^{redis graph read 'MATCH (k:kink) RETURN k.name'}
for (kink = `{echo $^p_kinks | sed 's/ /_/g; s/,/ /g'}) {
    if {in $kink $kinks} {
        redis graph write 'MATCH (u:user {username: '''$logged_user'''}),
                                 (k:kink {name: '''$kink'''})
                           MERGE (u)-[:KINK]->(k)'
    }
}

# Validate and set privacy setting
if {!~ $p_privacy everyone && !~ $p_privacy matches && !~ $p_privacy me} {
    throw error 'Invalid privacy setting'
} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       SET u.privacy_kinks = '''$p_privacy''''
}

# Update matches and proceed
compute_matches $logged_user
post_redirect '/settings#edit'
