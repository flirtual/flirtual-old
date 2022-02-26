% profile = `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})-[m:DAILYMATCH]->(p:user)
%                               RETURN p.username
%                               ORDER BY rand()
%                               LIMIT 1'}
% if {! isempty $profile} {
%     template tpl/profile.tpl $profile
% } {~ `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})
%                          RETURN exists(u.initial_matches)'} true} {
      <div class="box">
          <h1>Just a sec</h1>
          <h2>We're still computing your first matches.</h2>
          <p>Check back in a minute.</p>
          <a href="/" class="btn btn-gradient">Refresh</a>
      </div>
% } {~ `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})-[:MATCH]->(p:user)
%                          RETURN exists(p)'} true} {
      <div class="box">
          <h1>That's all</h1>
          <h2>You are out of matches for today.</h2>
          <p>Come back tomorrow for more!</p>
      </div>
% } {
      <div class="box">
          <h1>That's all</h1>
          <h2>You have run out of matches :(</h2>
          <p>To see more people, try changing your matchmaking filters, or invite more friends to Flirtual.</p>
          <a href="/onboarding/1" class="btn btn-gradient">Matchmaking</a>
      </div>
% }
