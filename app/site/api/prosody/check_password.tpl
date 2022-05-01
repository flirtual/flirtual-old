%{
if {! isempty $q_user && ! isempty $q_pass} {
    q_user = `{echo $q_user | tr 'A-Z' 'a-z'}
    (exists expiry expiryabs) = \
        `` \n {redis graph read 'MATCH (u:user)-[:SESSION]->(s:session {id: '''$^q_pass'''})
                                 WHERE toLower(u.username) = '''$^q_user'''
                                 RETURN exists(s), s.expiry, s.expiryabs'}
    if {~ $exists true &&
        gt $expiry $dateun &&
        gt $expiryabs $dateun} {
        echo -n true
    } {
        echo -n false
    }
} {
    echo -n false
}
%}
