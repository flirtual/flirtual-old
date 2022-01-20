%{
waves = `{redis graph read 'MATCH (a:user)-[w:WAVED]->(b:user {username: '''$logged_user'''})
                            WHERE NOT exists(a.onboarding) AND
                                  NOT (b)-[:PASSED]->(a)
                            RETURN a.username ORDER BY id(w) DESC'}
if {isempty $waves} {
    echo '<div class="box">'
    echo '    <h1>No notifications</h1>'
    echo '    <p>You''re all caught up!</p>'
    echo '    <a href="/" class="btn btn-mango">Go home</a>'
    echo '</div>'
} {
    for (profile = $waves) {
        echo '<div class="notice">Someone waved at you!</div>'
        template tpl/profile.tpl $profile
    }
}
%}
