%{
if {! isempty $p_user && echo $p_user | grep -s '^'$allowed_user_chars'+$'} {
    displayname = `{redis_html `{redis graph read 'MATCH (u:user {username: '''$p_user'''})
                                                   RETURN u.displayname'}}
}
%}

% if {~ $REQUEST_METHOD POST && ! isempty $p_id} {
      <div class="box">
          <h1>Thanks!</h1>
          <p>We've received your report and will review it as soon as possible.</p>
      </div>
% } {! isempty $displayname} {
      <div class="box">
          <h1>Report</h1>
          <form action="" method="POST" accept-charset="utf-8">
              <input type="hidden" name="id" value="%($p_user%)">

              <label for="displayname">User</label>
              <input type="text" id="displayname" value="%($^displayname%)" disabled>

              <label for="details">Details</label>
              <textarea id="details" name="details"></textarea><br /><br />

              <button type="submit" class="btn">Submit</button>
          </form>
      </div>
% } {
      <div class="box">
          <h1>User not found</h1>
          <p>Sorry, we couldn't find the user.</p>
      </div>
% }
