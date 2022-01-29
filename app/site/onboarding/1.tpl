%{
(survey_1 survey_2 survey_3 survey_4 survey_5 survey_6 survey_7 survey_8 survey_9) = \
    `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})
                        RETURN u.survey_1, u.survey_2, u.survey_3, u.survey_4, u.survey_5,
                               u.survey_6, u.survey_7, u.survey_8, u.survey_9'}

for (var = survey_1 survey_2 survey_3 survey_4 survey_5 survey_6 survey_7 survey_8 survey_9) {
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
    <p>These help VRLFP show you people with similar vibes and values. Other users won't see your answers.</p>

    <form action="" method="POST" accept-charset="utf-8">
        <table id="survey">
            <tr>
                <td><p>I daydream a lot</p></td>
                <td>
                    <div class="tags">
                        <input id="1_yes" type="radio" name="1" value="true" required %(`{if {~ $survey_1 true} { echo checked }}%)>
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
                        <input id="2_yes" type="radio" name="2" value="true" required %(`{if {~ $survey_2 true} { echo checked }}%)>
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
                        <input id="3_yes" type="radio" name="3" value="true" required %(`{if {~ $survey_3 true} { echo checked }}%)>
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
                        <input id="4_yes" type="radio" name="4" value="true" required %(`{if {~ $survey_4 true} { echo checked }}%)>
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
                        <input id="5_yes" type="radio" name="5" value="true" required %(`{if {~ $survey_5 true} { echo checked }}%)>
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
                        <input id="6_yes" type="radio" name="6" value="true" required %(`{if {~ $survey_6 true} { echo checked }}%)>
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
                        <input id="7_yes" type="radio" name="7" value="true" required %(`{if {~ $survey_7 true} { echo checked }}%)>
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
                        <input id="8_yes" type="radio" name="8" value="true" required %(`{if {~ $survey_8 true} { echo checked }}%)>
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
                        <input id="9_yes" type="radio" name="9" value="true" required %(`{if {~ $survey_9 true} { echo checked }}%)>
                        <label for="9_yes">Yes</label>
                        <input id="9_no" type="radio" name="9" value="false" %(`{if {~ $survey_9 false} { echo checked }}%)>
                        <label for="9_no">No</label>
                    </div>
                </td>
            </tr>
        </table>
%       if {! isempty $onboarding} {
            <button type="submit" class="btn btn-gradient">Next page</button>
%       } {
            <button type="submit" class="btn btn-gradient">Save</button>
%       }
    </form>
</div>

<script type="text/javascript">
    var survey = document.querySelector('#survey > tbody');
    for (var i = survey.children.length; i >= 0; i--) {
        survey.appendChild(survey.children[Math.random() * i | 0]);
    }
</script>
