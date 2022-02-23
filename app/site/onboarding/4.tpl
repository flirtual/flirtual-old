%{
(survey_1 survey_2 survey_3 survey_4 survey_5 survey_6 survey_7 survey_8 survey_9 privacy) = \
    `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})
                        RETURN u.survey_1, u.survey_2, u.survey_3, u.survey_4, u.survey_5,
                               u.survey_6, u.survey_7, u.survey_8, u.survey_9,
                               u.privacy_personality'}

for (var = survey_1 survey_2 survey_3 survey_4 survey_5 survey_6 survey_7 survey_8 survey_9 privacy) {
    if {! isempty $(p_$var)} {
        $var = $(p_$var)
    }
    if {isempty $var} {
        $var = ()
    }
}
%}

<div class="box">
    <h1>Personality</h1>
    <p>This helps us match you with compatible people, based on the Big 5 Personality Test. Your answers are hidden from other users. You can skip this and come back later.</p>

    <form action="" method="POST" accept-charset="utf-8">
        <table id="survey">
            <tr>
                <td><p>I daydream a lot</p></td>
                <td>
                    <div class="tags">
                        <input id="1_yes" type="radio" name="1" value="true" %(`{if {~ $survey_1 true} { echo checked }}%)>
                        <label for="1_yes">Yes</label>
                        <input id="1_no" type="radio" name="1" value="false" %(`{if {~ $survey_1 false} { echo checked }}%)>
                        <label for="1_no">No</label>
                    </div>
                </td>
            </tr>
            <tr>
                <td><p>I find many things beautiful</p></td>
                <td>
                    <div class="tags">
                        <input id="2_yes" type="radio" name="2" value="true" %(`{if {~ $survey_2 true} { echo checked }}%)>
                        <label for="2_yes">Yes</label>
                        <input id="2_no" type="radio" name="2" value="false" %(`{if {~ $survey_2 false} { echo checked }}%)>
                        <label for="2_no">No</label>
                    </div>
                </td>
            </tr>
            <tr>
                <td><p>I don't like it when things change</p></td>
                <td>
                    <div class="tags">
                        <input id="3_yes" type="radio" name="3" value="true" %(`{if {~ $survey_3 true} { echo checked }}%)>
                        <label for="3_yes">Yes</label>
                        <input id="3_no" type="radio" name="3" value="false" %(`{if {~ $survey_3 false} { echo checked }}%)>
                        <label for="3_no">No</label>
                    </div>
                </td>
            </tr>
            <tr>
                <td><p>I plan my life out</p></td>
                <td>
                    <div class="tags">
                        <input id="4_yes" type="radio" name="4" value="true" %(`{if {~ $survey_4 true} { echo checked }}%)>
                        <label for="4_yes">Yes</label>
                        <input id="4_no" type="radio" name="4" value="false" %(`{if {~ $survey_4 false} { echo checked }}%)>
                        <label for="4_no">No</label>
                    </div>
                </td>
            </tr>
            <tr>
                <td><p>Rules are important to follow</p></td>
                <td>
                    <div class="tags">
                        <input id="5_yes" type="radio" name="5" value="true" %(`{if {~ $survey_5 true} { echo checked }}%)>
                        <label for="5_yes">Yes</label>
                        <input id="5_no" type="radio" name="5" value="false" %(`{if {~ $survey_5 false} { echo checked }}%)>
                        <label for="5_no">No</label>
                    </div>
                </td>
            </tr>
            <tr>
                <td><p>I often do spontaneous things</p></td>
                <td>
                    <div class="tags">
                        <input id="6_yes" type="radio" name="6" value="true" %(`{if {~ $survey_6 true} { echo checked }}%)>
                        <label for="6_yes">Yes</label>
                        <input id="6_no" type="radio" name="6" value="false" %(`{if {~ $survey_6 false} { echo checked }}%)>
                        <label for="6_no">No</label>
                    </div>
                </td>
            </tr>
            <tr>
                <td><p>Deep down most people are good people</p></td>
                <td>
                    <div class="tags">
                        <input id="7_yes" type="radio" name="7" value="true" %(`{if {~ $survey_7 true} { echo checked }}%)>
                        <label for="7_yes">Yes</label>
                        <input id="7_no" type="radio" name="7" value="false" %(`{if {~ $survey_7 false} { echo checked }}%)>
                        <label for="7_no">No</label>
                    </div>
                </td>
            </tr>
            <tr>
                <td><p>I love helping people</p></td>
                <td>
                    <div class="tags">
                        <input id="8_yes" type="radio" name="8" value="true" %(`{if {~ $survey_8 true} { echo checked }}%)>
                        <label for="8_yes">Yes</label>
                        <input id="8_no" type="radio" name="8" value="false" %(`{if {~ $survey_8 false} { echo checked }}%)>
                        <label for="8_no">No</label>
                    </div>
                </td>
            </tr>
            <tr>
                <td><p>The truth is more important than people's feelings</p></td>
                <td>
                    <div class="tags">
                        <input id="9_yes" type="radio" name="9" value="true" %(`{if {~ $survey_9 true} { echo checked }}%)>
                        <label for="9_yes">Yes</label>
                        <input id="9_no" type="radio" name="9" value="false" %(`{if {~ $survey_9 false} { echo checked }}%)>
                        <label for="9_no">No</label>
                    </div>
                </td>
            </tr>
        </table><br />

        <label>Privacy: Who can see your personality traits?</label>
        <select name="privacy">
            <option value="everyone" %(`{if {~ $privacy everyone} { echo 'selected' }}%)>Anyone on Flirtual</option>
            <option value="matches" %(`{if {~ $privacy matches} { echo 'selected' }}%)>Matches only</option>
            <option value="me" %(`{if {~ $privacy me} { echo 'selected' }}%)>Just me</option>
        </select>

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

<style>
    input[type="radio"]:first-child + label {
        border-radius: 15px 0 0 15px;
        transform: translateX(11px);
    }
    input[type="radio"]:nth-child(3) + label {
        border-radius: 0 15px 15px 0;
    }
    input[type="radio"] + label {
        transition: background-color .3s, color .3s, box-shadow .3s !important;
        user-select: none;
    }
    input[type="radio"]:not(:checked) + label {
        position: relative;
        box-shadow: var(--shadow-2);
    }
    input[type="radio"]:not(:checked) + label + input[type="radio"]:not(:checked) + label::after {
        content: "";
        position: absolute;
        width: 17px;
        height: 2.5em;
        background-color: var(--grey);
        transform: translate(-59px, -5px);
    }
</style>

<script type="text/javascript">
    var survey = document.querySelector('#survey > tbody');
    for (var i = survey.children.length; i >= 0; i--) {
        survey.appendChild(survey.children[Math.random() * i | 0]);
    }
</script>
