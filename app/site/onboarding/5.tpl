%{
(age gender country bio language platform games socials \
 friends groups invite optout) = \
     `` \n {redis graph read 'MATCH (u:user {username: '''$logged_user'''})
                             RETURN u.privacy_age, u.privacy_gender, u.privacy_country,
                                    u.privacy_bio, u.privacy_language, u.privacy_platform,
                                    u.privacy_games, u.privacy_socials, u.privacy_friends,
                                    u.privacy_invite, u.optout'}
%}

<div class="box">
    <h1>Confirm your privacy settings</h1>

    <form action="" method="POST" accept-charset="utf-8">
        <label>Who can see your age?</label>
        <select name="age">
            <option value="public" %(`{if {~ $age public} { echo 'selected' }}%)>Public (anyone on the web)</option>
            <option value="vrlfp" %(`{if {~ $age vrlfp} { echo 'selected' }}%)>Anyone on VRLFP</option>
            <option value="friends" %(`{if {~ $age friends} { echo 'selected' }}%)>Friends only</option>
        </select>

        <label>Who can see your gender?</label>
        <select name="gender">
            <option value="public" %(`{if {~ $gender public} { echo 'selected' }}%)>Public (anyone on the web)</option>
            <option value="vrlfp" %(`{if {~ $gender vrlfp} { echo 'selected' }}%)>Anyone on VRLFP</option>
            <option value="friends" %(`{if {~ $gender friends} { echo 'selected' }}%)>Friends only</option>
        </select>

        <label>Who can see your country?</label>
        <select name="country">
            <option value="public" %(`{if {~ $country public} { echo 'selected' }}%)>Public (anyone on the web)</option>
            <option value="vrlfp" %(`{if {~ $country vrlfp} { echo 'selected' }}%)>Anyone on VRLFP</option>
            <option value="friends" %(`{if {~ $country friends} { echo 'selected' }}%)>Friends only</option>
        </select>

        <label>Who can see your bio?</label>
        <select name="bio">
            <option value="public" %(`{if {~ $bio public} { echo 'selected' }}%)>Public (anyone on the web)</option>
            <option value="vrlfp" %(`{if {~ $bio vrlfp} { echo 'selected' }}%)>Anyone on VRLFP</option>
            <option value="friends" %(`{if {~ $bio friends} { echo 'selected' }}%)>Friends only</option>
        </select>

        <label>Who can see your language?</label>
        <select name="language">
            <option value="public" %(`{if {~ $language public} { echo 'selected' }}%)>Public (anyone on the web)</option>
            <option value="vrlfp" %(`{if {~ $language vrlfp} { echo 'selected' }}%)>Anyone on VRLFP</option>
            <option value="friends" %(`{if {~ $language friends} { echo 'selected' }}%)>Friends only</option>
        </select>

        <label>Who can see your VR platform?</label>
        <select name="platform">
            <option value="public" %(`{if {~ $platform public} { echo 'selected' }}%)>Public (anyone on the web)</option>
            <option value="vrlfp" %(`{if {~ $platform vrlfp} { echo 'selected' }}%)>Anyone on VRLFP</option>
            <option value="friends" %(`{if {~ $platform friends} { echo 'selected' }}%)>Friends only</option>
        </select>

        <label>Who can see your favorite apps?</label>
        <select name="games">
            <option value="public" %(`{if {~ $games public} { echo 'selected' }}%)>Public (anyone on the web)</option>
            <option value="vrlfp" %(`{if {~ $games vrlfp} { echo 'selected' }}%)>Anyone on VRLFP</option>
            <option value="friends" %(`{if {~ $games friends} { echo 'selected' }}%)>Friends only</option>
        </select>

        <label>Who can see your social links?</label>
        <select name="socials">
            <option value="public" %(`{if {~ $socials public} { echo 'selected' }}%)>Public (anyone on the web)</option>
            <option value="vrlfp" %(`{if {~ $socials vrlfp} { echo 'selected' }}%)>Anyone on VRLFP</option>
            <option value="friends" %(`{if {~ $socials friends} { echo 'selected' }}%)>Friends only</option>
        </select>
        
        <label>Opt-out of anonymous statistics? <small>(<a href="/privacy#stats" target="_blank">Details</a>)</small></label>
        <select name="optout">
            <option value="false" %(`{if {~ $optout false} { echo 'selected' }}%)>Include me in statistics</option>
            <option value="true" %(`{if {~ $optout true} { echo 'selected' }}%)>Do not include me in statistics</option>
        </select>

        <button type="submit" name="back" value="true" class="btn btn-blueraspberry btn-back">Back</button>
        <button type="submit" class="btn btn-mango">Next page</button>
    </form>
</div>
