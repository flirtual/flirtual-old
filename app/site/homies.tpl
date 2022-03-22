% profile = `{redis graph read 'MATCH (u:user {username: '''$logged_user'''}), (p:user)
%                               WHERE u <> p AND
%                                     NOT (u)-[:LIKED]->(p) AND
%                                     NOT (u)-[:PASSED]->(p) AND
%                                     NOT (u)-[:HPASSED]->(p)
%                               RETURN p.username
%                               ORDER BY p.lastlogin DESC
%                               LIMIT 1'}

<div class="notice center">✌&#xFE0F; Homie Mode activated ✌&#xFE0F;</div>

% if {! isempty $profile} {
%     template tpl/profile.tpl $profile
% } {
      <div class="box">
          <h1>That's all</h1>
          <h2>You've seen everyone :(</h2>
          <p>Why not invite more friends to Flirtual?</p>
      </div>
% }
