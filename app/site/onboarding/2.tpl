%{
(women men other monopoly) = `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})
                                                 OPTIONAL MATCH (u)-[:LF]->(w:gender {name: ''Woman''})
                                                 OPTIONAL MATCH (u)-[:LF]->(m:gender {name: ''Man''})
                                                 OPTIONAL MATCH (u)-[:LF]->(o:gender {name: ''Other''})
                                                 RETURN exists(w), exists(m), exists(o), u.monopoly'}

for (r = `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})-[:LF]->(r:relationship) RETURN r.name'}) {
    $r = checked
}

for (g = `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})-[:LF]->(g:gender) RETURN g.name'}) {
    $g = checked
}

for (var = monopoly) {
    if {! isempty $(p_$var)} {
        $var = $(p_$var)
    }
    $var = `{redis_html $$var}
    if {isempty $$var} {
        $var = ()
    }
}
%}

<link rel="stylesheet" href="/css/quill.css">

<div class="box" style="margin-top: 0">
    <h1>Matchmaking</h1>

    <form id="form" action="" method="POST" accept-charset="utf-8">
        <label>What kind of relationship are you looking for?</label><br />
        <input id="homies" type="checkbox" name="Homies" value="true" %($Homies%)>
        <label for="homies">Homies</label><br />
        <input id="casual" type="checkbox" name="Casual_dating" value="true" %($Casual_dating%)>
        <label for="casual">Casual dating</label><br />
        <input id="serious" type="checkbox" name="Serious_dating" value="true" %($Serious_dating%)>
        <label for="serious">Serious dating</label><br />
        <input id="hookups" type="checkbox" name="Hookups" value="true" %($Hookups%)>
        <label for="hookups">Hookups</label><br />

        <a id="morebtn" class="btn" onclick="toggleMore()" style="font-size: 24px; margin: 24px 0 0 4px">More &#x25BC;</a>
        <div id="more" style="display: none; margin: -8px 0 -23px 0">
            <input id="monogamous" type="radio" name="monopoly" value="Monogamous" %(`{if {~ $monopoly Monogamous} { echo checked }}%)>
            <label for="monogamous">Monogamous</label><br />
            <input id="nonmonogamous" type="radio" name="monopoly" value="Non-monogamous" %(`{if {~ $monopoly Non-monogamous} { echo checked }}%)>
            <label for="nonmonogamous">Non-monogamous</label><br />
            <input id="both" type="radio" name="monopoly" value="Both">
            <label for="both">Open to both</label>
        </div><br /><br />

        <label>Who are you looking for?</label><br />
        <input id="women" type="checkbox" name="Women" value="true" %(`{if {~ $women true} { echo checked }}%)>
        <label for="women">Women</label><br />
        <input id="men" type="checkbox" name="Men" value="true" %(`{if {~ $men true} { echo checked }}%)>
        <label for="men">Men</label><br />
        <input id="other" type="checkbox" name="Other" value="true" %(`{if {~ $other true} { echo checked }}%)>
        <label for="other">Other</label>

%       if {! isempty $onboarding} {
            <button type="submit" class="btn btn-gradient">Next page</button>
%       } {
            <button type="submit" class="btn btn-gradient">Save</button>
%       }
    </form>
%   if {! isempty $onboarding} {
        <form id="form" action="" method="POST" accept-charset="utf-8">
            <button type="submit" name="back" value="true" class="btn btn-back">Back</button>
        </form>
%   }
</div>

<script type="text/javascript">
    function toggleMore() {
        var more = document.getElementById("more");
        if (more.style.display === "none") {
            more.style.display = "block";
            morebtn.innerHTML = "Less &#x25B2;";
        } else {
            more.style.display = "none";
            morebtn.innerHTML = "More &#x25BC;";
        }
    }
</script>
