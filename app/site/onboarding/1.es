require_login
if {! isempty $onboarding && !~ $onboarding 1} {
    post_redirect /
}

if {!~ $REQUEST_METHOD POST} { return 0 }

# Back button -> return to previous onboarding page
if {~ $p_back true} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''}) SET u.onboarding = 1'
    post_redirect /onboarding/1
}

redis graph write 'MATCH (u:user {username: '''$logged_user'''})-[i:INTERESTED_IN]->(t:tag) DELETE i'

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

tags = ($tags_social $tags_gaming $tags_genre $tags_life $tags_creation)
if {lt $#tags 3} {
    throw error 'Please select at least 3 tags'
}

# Write non-custom tags
for (category = social gaming genre life creation) {
    for (tag = $(tags_$category)) {
        redis graph write 'MATCH (u:user {username: '''$logged_user'''}),
                                 (t:tag {name: '''$tag''', category: '''$category'''})
                           CREATE (u)-[:INTERESTED_IN]->(t)'
    }
}

# Write custom tags
if {! isempty $p_custom} {
    for (tag = `{echo $p_custom | sed 's/ /_/g; s/,/ /g' | escape_redis}) {
        existingtag = `{redis graph read 'MATCH (t:tag {category: ''custom''})
                                          WHERE toLower(t.name) = '''`^{echo $tag | tr 'A-Z' 'a-z'}^'''
                                          RETURN t.name'}
        if {isempty $existingtag} {
            # Create new tag
            redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                               CREATE (u)-[:INTERESTED_IN]->(t:tag {name: '''$tag''', category: ''custom''})'
        } {
            # Existing tag; link to user
            redis graph write 'MATCH (u:user {username: '''$logged_user'''}),
                                     (t:tag {name: '''$existingtag''', category: ''custom''})
                               CREATE (u)-[:INTERESTED_IN]->(t)'
        }
    }
}

# Proceed
if {! isempty $onboarding} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       SET u.onboarding = 2'
    post_redirect /onboarding/2
} {
    post_redirect '/settings#edit'
}
