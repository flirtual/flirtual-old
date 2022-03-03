require_login

# Disable Homie Mode if we have daily matches
if {~ `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})-[m:DAILYMATCH]->(p:user)
                          RETURN DISTINCT exists(p)'} true} {
    post_redirect /
}
