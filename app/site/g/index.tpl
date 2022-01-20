<div class="box">
    <h1>Groups</h1>
    <p>🚧 <a href="/roadmap" target="_blank">Under construction</a> 🚧</p><p>A list of cool VR community groups and Discords to join.</p><br />
    <p><a href="/g/create" class="btn btn-blueraspberry btn-normal">Create a community group</a></p>
</div>

%{
joined_groups = `{redis graph read 'MATCH (g:group),
                                          (u:user {username: '''$logged_user'''})
                                    WHERE (u)-[:MEMBER]->(g)
                                    RETURN g.url
                                    ORDER BY g.name'}
if {! isempty $joined_groups} {
    echo '<br /><h1>Your Groups</h1>'

    for (url = $joined_groups) {
        template tpl/grouppreview.tpl $url
    }
}

public_groups = `{redis graph read 'MATCH (g:group {type: ''public''}),
                                          (u:user {username: '''$logged_user'''})
                                    WHERE g.type = ''public'' AND
                                          NOT (u)-[:MEMBER]->(g)
                                    RETURN g.url
                                    ORDER BY rand()
                                    LIMIT 10'}
if {! isempty $public_groups} {
    echo '<br /><h1>Public Groups</h1>'

    for (url = $public_groups) {
        template tpl/grouppreview.tpl $url
    }
}
%}
