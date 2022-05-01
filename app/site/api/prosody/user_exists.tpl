%{
q_user = `{echo $q_user | tr 'A-Z' 'a-z'}
if {! isempty $q_user &&
    ~ `{redis graph read 'MATCH (u:user)
                          WHERE toLower(u.username) = '''$^q_user'''
                          RETURN exists(u)'} true} {
    echo -n true
} {
    echo -n false
}
%}
