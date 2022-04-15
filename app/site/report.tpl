%{
if {! isempty $p_user && echo $p_user | grep -s '^[a-zA-Z0-9_\-]+$'} {
    displayname = `{redis_html `{redis graph read 'MATCH (u:user {id: '''$p_user'''})
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

              <label for="reason">Reason</label>
              <select name="reason">
                  <option value="Spam or troll account">Spam or troll account</option>
                  <option value="Hateful content">Hateful content</option>
                  <option value="Violent or disturbing content">Violent or disturbing content</option>
                  <option value="Nude or NSFW pictures">Nude or NSFW pictures</option>
                  <option value="Harassment">Harassment</option>
                  <option value="Impersonating me or someone else">Impersonating me or someone else</option>
                  <option value="Scam, malware, or harmful links">Scam, malware, or harmful links</option>
                  <option value="Advertising">Advertising</option>
                  <option value="Underage user">Underage user</option>
                  <option value="Illegal content">Illegal content</option>
                  <option value="Self-harm content">Self-harm content</option>
                  <option value="Other">Other</option>
              </select>

              <label for="details">Details</label>
              <textarea id="details" name="details" placeholder="If you have proof of an offense that doesn't appear on their profile, please include a link or your contact info."></textarea><br /><br />

              <button type="submit" class="btn">Submit</button>
          </form>
      </div>
% } {
      <div class="box">
          <h1>User not found</h1>
          <p>Sorry, we couldn't find the user.</p>
      </div>
% }
