require_login

if {!~ $REQUEST_METHOD POST} { post_redirect /g/ }

# Validate group, existence
if {! echo $p_group | grep -s '^[a-zA-Z0-9_\-]+$' ||
    !~ `{redis graph read 'MATCH (g:group {invite: '''$p_group'''}) RETURN exists(g)'} true} {
    return 0
}

# Join/leave the group
if {~ $p_action join} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''}),
                             (g:group {invite: '''$p_group'''})
                       CREATE (u)-[:MEMBER]->(g)'
} {~ $p_action leave} {
    # Admins can't leave groups
    if {~ `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})-[a:ADMINS]->(g:group {invite: '''$p_group'''})
                              RETURN exists(a)'} true} {
        throw error 'Sorry, admins can''t leave groups at this time. Please <a href="https://rovr.atlassian.net/servicedesk/customer/portal/3/group/4/create/46" target="_blank">contact us</a> if you''d like to transfer or delete your group'
    }

    redis graph write 'MATCH (u:user {username: '''$logged_user'''})-[r]->(g:group {invite: '''$p_group'''})
                       DELETE r'
}

# Back to the group page
post_redirect /g/`{redis graph read 'MATCH (g:group {invite: '''$p_group'''}) RETURN g.url'}
