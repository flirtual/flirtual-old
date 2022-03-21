%{
(women men other serious monopoly agemin agemax) = \
    `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})
                        OPTIONAL MATCH (u)-[:LF]->(w:gender {name: ''Woman''})
                        OPTIONAL MATCH (u)-[:LF]->(m:gender {name: ''Man''})
                        OPTIONAL MATCH (u)-[:LF]->(o:gender {name: ''Other''})
                        RETURN exists(w), exists(m), exists(o), u.serious, u.monopoly, u.agemin, u.agemax'}

for (g = `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})-[:LF]->(g:gender) RETURN g.name'}) {
    $g = checked
}

for (var = women men other serious monopoly agemin agemax) {
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
        <label>I want to meet...<span class="required" aria-label="Required" role="tooltip" data-microtip-position="top">*</span></label><br />
        <input id="women" type="checkbox" name="Women" value="true" %(`{if {~ $women true} { echo checked }}%)>
        <label for="women">Women</label><br />
        <input id="men" type="checkbox" name="Men" value="true" %(`{if {~ $men true} { echo checked }}%)>
        <label for="men">Men</label><br />
        <input id="other" type="checkbox" name="Other" value="true" %(`{if {~ $other true} { echo checked }}%)>
        <label for="other">Other genders</label><br />

        <label for="agemin">Age range<span class="required" aria-label="Required" role="tooltip" data-microtip-position="top">*</span></label>
        <select name="agemin" style="width: auto; margin-top: 12px">
            <option value="18" %(`{if {~ $agemin 18 || isempty $agemin} { echo 'selected' }}%)>18</option>
%           for (age = `{seq 19 125}) {
                <option value="%($age%)" %(`{if {~ $agemin $age} { echo 'selected' }}%)>%($age%)</option>
%           }
        </select>
        -
        <select name="agemax" style="width: auto">
            <option hidden disabled selected value></option>
%           for (age = `{seq 18 124}) {
                <option value="%($age%)" %(`{if {~ $agemax $age} { echo 'selected' }}%)>%($age%)</option>
%           }
            <option value="125" %(`{if {~ $agemax 125 || isempty $agemax} { echo 'selected' }}%)>125</option>
        </select><br /><br />

        <label>Are you open to serious dating?</label><br />
        <div class="tags" style="margin: 8px 0 0 -7px">
            <input id="serious_yes" type="radio" name="serious" value="true" %(`{if {~ $serious true} { echo checked }}%)>
            <label for="serious_yes">Yes</label>
            <input id="serious_no" type="radio" name="serious" value="false" %(`{if {~ $serious false} { echo checked }}%)>
            <label for="serious_no">No</label>
        </div>

        <a id="morebtn" class="btn" onclick="toggleMore()" style="font-size: 24px; margin: 65px 0 0 4px">More &#x25BC;</a>
        <div id="more" style="display: none; margin: -8px 0 -23px 0">
            <input id="monogamous" type="radio" name="monopoly" value="Monogamous" %(`{if {~ $monopoly Monogamous} { echo checked }}%)>
            <label for="monogamous">Monogamous</label><br />
            <input id="nonmonogamous" type="radio" name="monopoly" value="Non-monogamous" %(`{if {~ $monopoly Non-monogamous} { echo checked }}%)>
            <label for="nonmonogamous">Non-monogamous</label><br />
            <input id="both" type="radio" name="monopoly" value="Both">
            <label for="both">Open to both</label>
        </div>

%       if {isempty $onboarding} {
            <p>Changes you make to your matchmaking preferences will be applied tomorrow.</p>
%       }
        <p><span class="required">*</span> = required</p>

%       if {! isempty $onboarding} {
            <button type="submit" class="btn btn-gradient">Next page</button>
%       } {
            <button type="submit" class="btn btn-gradient">Save</button>
%       }
    </form>
</div>

<style>
    .tags input[type="radio"]:first-child + label {
        border-radius: 15px 0 0 15px;
        transform: translateX(11px);
    }
    .tags input[type="radio"]:nth-child(3) + label {
        border-radius: 0 15px 15px 0;
    }
    .tags input[type="radio"] + label {
        transition: background-color .3s, color .3s, box-shadow .3s !important;
        user-select: none;
    }
    .tags input[type="radio"]:not(:checked) + label {
        position: relative;
        box-shadow: var(--shadow-2);
    }
    .tags input[type="radio"]:not(:checked) + label + input[type="radio"]:not(:checked) + label::after {
        content: "";
        position: absolute;
        width: 17px;
        height: 2.5em;
        background-color: var(--grey);
        transform: translate(-59px, -5px);
    }
</style>

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
