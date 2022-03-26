%{
(theme nsfw personality socials sexuality country kinks optout match_emails like_emails newsletter \
 volume) = \
    `` \n {redis graph read 'MATCH (u:user {username: '''$logged_user'''})
                             RETURN u.theme, u.nsfw, u.privacy_personality, u.privacy_socials,
                                    u.privacy_sexuality, u.privacy_country, u.privacy_kinks,
                                    u.optout, u.match_emails, u.like_emails, u.newsletter,
                                    u.volume'}
%}

% if {! isempty $q_update_success} {
    <div class="notice success">%($q_update_success%) updated successfully!</div>
% }

<div style="margin-top: -100px">
    <a onclick="document.getElementById('edit').scrollIntoView()" class="btn" style="margin: 0 1em 1em 0">Profile</a>
    <a onclick="document.getElementById('notifications').scrollIntoView()" class="btn" style="margin: 0 1em 1em 0">Notifications</a>
    <a onclick="document.getElementById('privacy').scrollIntoView()" class="btn" style="margin: 0 1em 1em 0">Privacy</a>
    <a onclick="document.getElementById('account').scrollIntoView()" class="btn" style="margin: 0 1em 1em 0">Account</a>
</div>

<span id="edit"></span>
<div class="box">
    <h1>Profile</h1><br />
    <a href="/onboarding/1" class="btn btn-normal">Matchmaking</a>
    <a href="/onboarding/2" class="btn btn-normal">Basic info</a>
    <a href="/onboarding/3" class="btn btn-normal">Bio & pics</a>
    <a href="/onboarding/4" class="btn btn-normal">Personality</a>
    <a href="/nsfw" class="btn btn-normal">NSFW</a>
    <a href="/%($logged_user%)" class="btn btn-gradient">View profile</a>
</div>

<span id="notifications"></span>
<div class="box">
    <h1>Notifications</h1>
    <form action="" method="POST" accept-charset="utf-8">
        <input type="checkbox" name="match_emails" id="match_emails" value="true" %(`{if {~ $match_emails true} { echo checked }}%)>
        <label for="match_emails">Match notifications</label><br />
        <input type="checkbox" name="like_emails" id="like_emails" value="true" %(`{if {~ $like_emails true} { echo checked }}%)>
        <label for="like_emails">Weekly profile like reminders</label><br />
        <input type="checkbox" name="newsletter" id="newsletter" value="true" %(`{if {~ $newsletter true} { echo checked }}%)>
        <label for="newsletter">Product updates (we won't spam you)</label><br style="margin-bottom: 1em; display: block; content: ''" />

        <label for="volume">Message notification volume</label><a onclick="document.getElementById('message_audio').currentTime = 0; document.getElementById('message_audio').play()" class="btn btn-small" style="transform: translate(-12px, 12px)">Test</a><br />
        <input type="range" min="0" max="1" step="0.01" id="volume" name="volume" value="%($volume%)" onchange="document.getElementById('message_audio').volume = this.value"><br /><br />

        <button type="submit" name="changenotifications" value="true" class="btn btn-gradient">Save</button>
    </form>
</div>

<span id="privacy"></span>
<div class="box">
    <h1>Privacy</h1>
    <form action="" method="POST" accept-charset="utf-8">
        <label>Who can see your personality traits?</label>
        <select name="personality">
            <option value="everyone" %(`{if {~ $personality everyone} { echo 'selected' }}%)>Anyone on Flirtual</option>
            <option value="matches" %(`{if {~ $personality matches} { echo 'selected' }}%)>Matches only</option>
            <option value="me" %(`{if {~ $personality me} { echo 'selected' }}%)>Just me</option>
        </select>

        <label>Who can see your linked accounts? (VRChat, Discord)</label>
        <select name="socials">
            <option value="everyone" %(`{if {~ $socials everyone} { echo 'selected' }}%)>Anyone on Flirtual</option>
            <option value="matches" %(`{if {~ $socials matches} { echo 'selected' }}%)>Matches only</option>
            <option value="me" %(`{if {~ $socials me} { echo 'selected' }}%)>Just me</option>
        </select>

        <label>Who can see your sexuality?</label>
        <select name="sexuality">
            <option value="everyone" %(`{if {~ $sexuality everyone} { echo 'selected' }}%)>Anyone on Flirtual</option>
            <option value="matches" %(`{if {~ $sexuality matches} { echo 'selected' }}%)>Matches only</option>
            <option value="me" %(`{if {~ $sexuality me} { echo 'selected' }}%)>Just me</option>
        </select>

        <label>Who can see your country?</label>
        <select name="country">
            <option value="everyone" %(`{if {~ $country everyone} { echo 'selected' }}%)>Anyone on Flirtual</option>
            <option value="matches" %(`{if {~ $country matches} { echo 'selected' }}%)>Matches only</option>
            <option value="me" %(`{if {~ $country me} { echo 'selected' }}%)>Just me</option>
        </select>

%       if {~ $nsfw true} {
            <label>Who can see your NSFW tags?</label>
            <select name="kinks">
                <option value="everyone" %(`{if {~ $kinks everyone} { echo 'selected' }}%)>Anyone with NSFW enabled on Flirtual</option>
                <option value="matches" %(`{if {~ $kinks matches} { echo 'selected' }}%)>Matches only</option>
                <option value="me" %(`{if {~ $kinks me} { echo 'selected' }}%)>Just me</option>
            </select>
%       }

        <label>Opt-out of anonymous statistics? <small>(<a href="/privacy" target="_blank">Details</a>)</small></label>
        <select name="optout">
            <option value="false" %(`{if {~ $optout false} { echo 'selected' }}%)>Include me in statistics</option>
            <option value="true" %(`{if {~ $optout true} { echo 'selected' }}%)>Do not include me in statistics</option>
        </select>

        <button type="submit" name="changeprivacy" value="true" class="btn btn-gradient">Save</button>
    </form>
</div>

<span id="account"></span>
<span id="changedemail"></span>
<span id="changedpassword"></span>
<div class="box">
    <h1>Account</h1>

%   if {~ $req_path '/settings#changedpassword'} {
        <p>Your password has been changed successfully!</p><br />
%   }

    <h2>Change your email</h2>
    <form action="" method="POST" accept-charset="utf-8">
        <label for="newemail">Email</label>
        <input type="text" name="newemail" id="newemail" required autocomplete="email" value="%(`{echo $^p_newemail | escape_html}%)">

        <label for="confirmpassword">Confirm password</label>
        <input type="password" name="confirmpassword" id="confirmpassword" required autocomplete="current-password">

        <button type="submit" name="changeemail" value="true" class="btn btn-gradient" style="margin: 1em 0 0.5em auto">Update</button>
    </form>

    <h2>Change your password</h2>
    <form action="" method="POST" accept-charset="utf-8">
        <label for="currentpassword">Current password</label>
        <input type="password" name="currentpassword" id="currentpassword" required autocomplete="current-password">

        <label for="newpassword">New password</label>
        <input type="password" name="newpassword" id="newpassword" required autocomplete="new-password">

        <button type="submit" name="changepassword" value="true" class="btn btn-gradient" style="margin: 1em 0 0.5em auto">Update</button>
    </form>

    <h2>Danger Zone</h2>
    <a href="/deleteaccount" class="btn btn-normal" style="top: 0 !important; right: 0 !important">Delete account</a>
</div>

<script>
    // This is a long page with multiple forms which introduces two challenges:
    // (1) We sometimes link to different sections of the page with URL #hashes. If the user submits
    //     a form and there's an error, they won't see it because it's at the top of the page and
    //     they're scrolled to the #hash section.
    // (2) We display different success messages using ?query strings. If the user reloads the page,
    //     we want to hide these messages.
    // So, we use the following function to remove any #hashes and ?query strings from the URL when
    // the page loads. Also, the navigation buttons at the top use scrollIntoView() instead of
    // normal #hash links :(
    window.addEventListener('load', function(event) {
        history.replaceState("", document.title, window.location.href.split(/[?#]/)[0]);
    }, true)
</script>
