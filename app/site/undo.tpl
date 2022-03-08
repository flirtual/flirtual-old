% profile = `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})-[:UNDO]->(p:user)
%                               RETURN p.username
%                               LIMIT 1'}
% if {! isempty $profile} {
%     template tpl/profile.tpl $profile
% }
