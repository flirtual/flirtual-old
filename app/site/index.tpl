% if {logged_in} {
%     profile = `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})-[m:DAILYMATCH]->(p:user)
%                                   RETURN p.username
%                                   LIMIT 1'}
%     if {! isempty $profile} {
%         template tpl/profile.tpl $profile
%     } {~ `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})-[:MATCH]->(p:user)
%                              RETURN exists(p)'} true} {
          <div class="box">
              <h1>You did it!</h1>
              <h2>That's all your matches for today.</h2>
              <p>Come back tomorrow for more!</p>
          </div>
%     } {
          <div class="box">
              <h1>That's all!</h1>
              <h2>You've run out of matches :(</h2>
              <p>Try adjusting your matchmaking filters to see more people, or invite your friends!</p>
              <a href="/onboarding/1" class="btn btn-gradient">Matchmaking</a>
          </div>
%     }
% } {
      <h1 style="position: absolute; left: 50%; top: 50%; transform: translate(-50%, -50%)">Coming soon to a reality near you.</h1>
      <style>footer { display: none }</style>
% }
