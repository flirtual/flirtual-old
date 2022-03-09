%{
(nsfw domsub privacy) = `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})
                                    RETURN u.nsfw, u.domsub, u.privacy_kinks'}

kinks = `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})-[:KINK]->(k:kink)
                            RETURN k.name ORDER BY k.order'}

for (var = nsfw domsub kinks) {
    if {! isempty $(p_$var)} {
        $var = $(p_$var)
    }
    $var = `{redis_html $$var}
    if {isempty $$var} {
        $var = ()
    }
}
%}

<div class="box" style="margin-top: 0">
    <h1>NSFW</h1>

    <form id="form" action="" method="POST" accept-charset="utf-8">
        <input id="nsfw" type="checkbox" name="nsfw" value="true" onclick="toggleNSFW()" %(`{if {~ $nsfw true} { echo checked }}%)>
        <label for="nsfw">Enable NSFW tags?</label><br /><br />

        <div id="nsfwtags" %(`{if {!~ $nsfw true} { echo 'style="display: none"' }}%)>
            <label>What's your preference?</label><br />
            <input id="dominant" type="radio" name="domsub" value="Dominant" %(`{if {~ $domsub Dominant} { echo checked }}%)>
            <label for="dominant">Dominant</label><br />
            <input id="submissive" type="radio" name="domsub" value="Submissive" %(`{if {~ $domsub Submissive} { echo checked }}%)>
            <label for="submissive">Submissive</label><br />
            <input id="switch" type="radio" name="domsub" value="Switch" %(`{if {~ $domsub Switch} { echo checked }}%)>
            <label for="switch">Switch</label><br /><br />

            <label for="kinks">Kinks</label>
            <input name="kinks" id="kinks" value="%(`{echo $^kinks | sed 's/ /,/g; s/_/ /g'}%)">

            <label>Privacy: Who can see your NSFW tags?</label>
            <select name="privacy">
                <option value="everyone" %(`{if {~ $privacy everyone} { echo 'selected' }}%)>Anyone on Flirtual</option>
                <option value="matches" %(`{if {~ $privacy matches} { echo 'selected' }}%)>Matches only</option>
                <option value="me" %(`{if {~ $privacy me} { echo 'selected' }}%)>Just me</option>
            </select>
        </div>

        <button type="submit" class="btn btn-gradient">Save</button>
    </form>
</div>

<script type="text/javascript">
    function toggleNSFW() {
        var nsfw = document.getElementById("nsfwtags");
        if (document.getElementById("nsfw").checked) {
            nsfw.style.display = "block";
        } else {
            nsfw.style.display = "none";
        }
    }

    var tagify_kinks = new Tagify(document.querySelector('input[name=kinks]'), {
        enforceWhitelist: true,
        whitelist: [
%           for (kink = `` \n {redis graph read 'MATCH (k:kink)
%                                                RETURN k.name
%                                                ORDER BY k.order' | sed 's/_/ /g'}) {
                "%($kink%)",
%           }
        ],
        maxTags: 10,
        skipInvalid: true,
        originalInputValueFormat: valuesArr => valuesArr.map(item => item.value).join(','),
        dropdown: {
            enabled: 0,
            maxItems: 0
        }
    })
</script>
