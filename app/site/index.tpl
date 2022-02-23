% if {logged_in} {
%     profile = `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})-[m:DAILYMATCH]->(p:user)
%                                   RETURN p.username
%                                   ORDER BY rand()
%                                   LIMIT 1'}
%     if {! isempty $profile} {
%         template tpl/profile.tpl $profile
%     } {~ `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})
%                              RETURN exists(u.initial_matches)'} true} {
          <div class="box">
              <h1>Just a sec!</h1>
              <h2>We're still computing your first matches.</h2>
              <p>Check back in a minute.</p>
              <a href="/" class="btn btn-gradient">Refresh</a>
          </div>
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
      <h1>Flirtual<br /><small>(formerly VRLFP)</small></h1>
      <h2>Go on Dates<br />...in Virtual Reality</h2><br />
      <h1 style="font-size: 300%">Coming soon&trade;</h1>
      <!--
      <a href="/register" class="btn btn-gradient">Sign up</a>
      <a href="/login" class="btn">Login</a>
      -->

      <style>
          body {
              height: 100vh;
              background: var(--gradient);
              color: var(--white);
              text-align: center;
          }
          h1 {
              font-family: Montserrat, sans-serif;
              font-size: 400%;
          }
          small {
              display: block;
              font-size: 40%;
              transform: translateY(-8px);
          }
          footer {
              display: none;
          }
      </style>
% }
