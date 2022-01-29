<h1>Your Guest List</h1>

%{
guests = `{redis graph write 'MATCH (u:user {username: '''$logged_user'''})-[:GUEST]->(g:user),
                                    (u:user {username: '''$logged_user'''})-[m:MATCH]->(g:user)
                              WHERE NOT (u)-[:FRIENDS]-(g) AND
                                    NOT (u)-[:WAVED]->(g) AND
                                    NOT (u)-[:PASSED]->(g)
                              MERGE (u)-[s:SEEN]->(g)
                              ON CREATE SET s.date = '$dateun'
                              RETURN g.username
                              ORDER BY m.score DESC'}
%}

% if {! isempty $guests} {
%     for (profile = $guests) {
          <br /><br />
%         template tpl/profile.tpl $profile
%     }
% } {! isempty `{redis graph read 'MATCH (u:user {username: '''$logged_user'''}) RETURN u.genguestlist'}} {
      <div class="box">
          <h1>Guest List</h1>
          <p>We're still generating your guest list! Please check back in a couple minutes.</p>
	  <a href="/guestlist" class="btn">Reload</a>
      </div>
% } {
      <div class="box">
          <h1>That's all for today!</h1>
          <p>Come back tomorrow for more guests.</p>

%         if {! isempty `{redis graph read 'MATCH (a:user)-[w:WAVED]->(b:user {username: '''$logged_user'''})
%                                           WHERE NOT exists(a.onboarding) AND
%                                                 NOT (b)-[:PASSED]->(a)
%                                           RETURN exists(a)'}} {
              <p>Check your <a href="/notifications">notifications</a> to see who's waved at you.</p>
%         }
      </div>
% }
