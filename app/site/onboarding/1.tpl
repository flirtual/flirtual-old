%{
(women men other serious monopoly agemin agemax nsfw weight_likes weight_default_interests \
 weight_custom_interests weight_personality weight_games weight_country weight_serious \
 weight_monopoly weight_domsub weight_kinks) = \
    `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})
                        OPTIONAL MATCH (u)-[:LF]->(w:gender {name: ''Woman''})
                        OPTIONAL MATCH (u)-[:LF]->(m:gender {name: ''Man''})
                        OPTIONAL MATCH (u)-[:LF]->(o:gender {name: ''Other''})
                        RETURN exists(w), exists(m), exists(o), u.serious, u.monopoly, u.agemin,
                               u.agemax, u.nsfw, u.weight_likes, u.weight_default_interests,
                               u.weight_custom_interests, u.weight_personality, u.weight_games,
                               u.weight_country, u.weight_serious, u.weight_monopoly,
                               u.weight_domsub, u.weight_kinks'}

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

%       if {isempty $onboarding && ~ $beta true} {
            <br /><br /><h2>Matchmaking weights</h2>
            <p>
                Flirtual Supporters can personalize their matchmaking algorithm.
%               if {~ $supporter true} {
                    What's most important to you?
%               } {
                    <br /><br /><a href="/premium" class="btn btn-gradient btn-normal">Subscribe</a>
%               }
            </p>
            <label for="weight_default_interests">Standard interests in common</label>
            <input type="range" min="0" max="2.004" step="0.334" id="weight_default_interests" name="weight_default_interests" value="%($weight_default_interests%)" %(`{if {~ $supporter false} { echo 'disabled' }}%)>
            <label for="weight_custom_interests">Custom interests in common</label>
            <input type="range" min="0" max="2.004" step="0.334" id="weight_custom_interests" name="weight_custom_interests" value="%($weight_custom_interests%)" %(`{if {~ $supporter false} { echo 'disabled' }}%)>
            <label for="weight_personality">Personality similarity</label>
            <input type="range" min="0" max="2.004" step="0.334" id="weight_personality" name="weight_personality" value="%($weight_personality%)" %(`{if {~ $supporter false} { echo 'disabled' }}%)>
            <label for="weight_games">Social VR games in common</label>
            <input type="range" min="0" max="2.004" step="0.334" id="weight_games" name="weight_games" value="%($weight_games%)" %(`{if {~ $supporter false} { echo 'disabled' }}%)>
            <label for="weight_country">Same country</label>
            <input type="range" min="0" max="2.004" step="0.334" id="weight_country" name="weight_country" value="%($weight_country%)" %(`{if {~ $supporter false} { echo 'disabled' }}%)>
%           if {~ $serious true} {
                <label for="weight_serious">Open to serious dating</label>
                <input type="range" min="0" max="2.004" step="0.334" id="weight_serious" name="weight_serious" value="%($weight_serious%)" %(`{if {~ $supporter false} { echo 'disabled' }}%)>
%           }
%           if {! isempty $monopoly} {
                <label for="weight_monopoly">Monogamous/non-monogamous match</label>
                <input type="range" min="0" max="2.004" step="0.334" id="weight_monopoly" name="weight_monopoly" value="%($weight_monopoly%)" %(`{if {~ $supporter false} { echo 'disabled' }}%)>
%           }
%           if {~ $nsfw true} {
                <label for="weight_domsub">
                    Dom/sub/switch match
                    <span class="required" aria-label="Coming soon: this isn't factored into matchmaking yet" role="tooltip" data-microtip-position="top">🚧</span>
                </label>
                <input type="range" min="0" max="2.004" step="0.334" id="weight_domsub" name="weight_domsub" value="%($weight_domsub%)" %(`{if {~ $supporter false} { echo 'disabled' }}%)>
                <label for="weight_kinks">
                    Kink matches
                    <span class="required" aria-label="Coming soon: this isn't factored into matchmaking yet" role="tooltip" data-microtip-position="top">🚧</span>
                </label>
                <input type="range" min="0" max="2.004" step="0.334" id="weight_kinks" name="weight_kinks" value="%($weight_kinks%)" %(`{if {~ $supporter false} { echo 'disabled' }}%)>
%           }
            <label for="weight_likes">
                People who have liked you
                <span class="required" aria-label="You may need to lower this to prioritize other weights" role="tooltip" data-microtip-position="top">❓</span>
            </label>
            <input type="range" min="0" max="2.004" step="0.334" id="weight_likes" name="weight_likes" value="%($weight_likes%)" %(`{if {~ $supporter false} { echo 'disabled' }}%)>
%       }

%       if {~ $premium true} {
            <p>Changes you make to your matchmaking preferences will take a couple minutes to apply.</p>
%       } {isempty $onboarding} {
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
