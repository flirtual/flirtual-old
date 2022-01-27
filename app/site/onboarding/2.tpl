%{
(displayname dob gender country) = \
    `` \n {redis graph read 'MATCH (u:user {username: '''$logged_user'''})
                             OPTIONAL MATCH (u)-[:COUNTRY]->(c:country)
                             RETURN u.displayname, u.dob, u.gender, c.id'}

languages = `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})-[:KNOWS]->(l:language)
                                RETURN l.id'}

for (p = `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})-[:USES]->(p:platform) RETURN p.name'}) {
    $p = checked
}

for (var = displayname dob gender country languages platform) {
    if {! isempty $(p_$var)} {
        $var = $(p_$var)
    }
    $var = `{redis_html $$var}
    if {isempty $$var} {
        $var = ()
    }
}
%}

<script src="/js/intlpolyfill.js"></script>

<div class="box" style="margin-top: 0">
%   if {! isempty $onboarding} {
        <h1>More about you</h1>
%   } {
        <h1>Some basic info</h1>
%   }

    <form id="form" action="" method="POST" accept-charset="utf-8">
        <label for="displayname">Display name (optional)</label>
        <input type="text" name="displayname" id="displayname" value="%($displayname%)">
        <p class="help_text">This is how you'll appear around VRLFP . Unlike your username (%($logged_user%)), your display name can contain special characters and doesn't need to be unique. Your profile link (vrlfp.com/%($logged_user%)) will still use your username.</p>

        <label for="dob">Date of birth (optional, only your age will be visible)</label>
        <input type="date" name="dob" id="dob" autocomplete="bday" placeholder="YYYY-MM-DD" value="%($dob%)">

        <label for="gender">Gender</label><br />
        <input type="checkbox" name="gender" id="man" value="Man" class="gendercheckbox" onclick="checkGender(this)" %(`{if {~ $gender Man} { echo checked }}%)>
        <label for="man">Man</label><br />
        <input type="checkbox" name="gender" id="woman" value="Woman" class="gendercheckbox" onclick="checkGender(this)" style="margin-top: 12px" %(`{if {~ $gender Woman} { echo checked }}%)>
        <label for="woman">Woman</label><br />
        <table>
            <tr>
                <td style="width: 1px; white-space: nowrap; transform: translateX(-2px)">
                    <input type="checkbox" name="gender" id="other" value="Other" class="gendercheckbox" onclick="checkGender(this)" %(`{if {! isempty $gender && !~ $gender Man && !~ $gender Woman} { echo checked }}%)>
                    <label for="other">Other:</label>
                </td>
                <td style="width: 100%">
                    <input name="gender_other" id="gender_other" value="%(`{if {! isempty $gender && !~ $gender Man && !~ $gender Woman} { echo $gender }}%)"></input>
                </td>
            </tr>
        </table>

        <label for="country">Country (optional)</label>
        <input name="country" id="country" class="countries" value="%($country%)">

        <label for="language">Language(s)</label>
        <input name="language" id="language" required>

        <label>VR platform(s)</label>
        <div class="tags">
            <input id="quest" type="checkbox" name="Oculus_Quest" value="true" class="vrcheckbox" onclick="haveVR(this)" %($Oculus_Quest%)>
            <label for="quest">Oculus Quest</label>
            <input id="link" type="checkbox" name="Oculus_Link" value="true" class="vrcheckbox" onclick="haveVR(this)" %($Oculus_Link%)>
            <label for="link">Oculus Quest with Link</label>
            <input id="rift" type="checkbox" name="Oculus_Rift" value="true" class="vrcheckbox" onclick="haveVR(this)" %($Oculus_Rift%)>
            <label for="rift">Oculus Rift (S)</label>
            <input id="steamvr" type="checkbox" name="SteamVR" value="true" class="vrcheckbox" onclick="haveVR(this)" %($SteamVR%)>
            <label for="steamvr">SteamVR (Index, Vive, Pimax, etc.)</label>
            <input id="wmr" type="checkbox" name="Windows_Mixed_Reality" value="true" class="vrcheckbox" onclick="haveVR(this)" %($Windows_Mixed_Reality%)>
            <label for="wmr">Windows Mixed Reality (Reverb, Odyssey, etc.)</label>
            <input id="psvr" type="checkbox" name="PlayStation_VR" value="true" class="vrcheckbox" onclick="haveVR(this)" %($PlayStation_VR%)>
            <label for="psvr">PlayStation VR</label>
            <input id="desktop" type="checkbox" name="Desktop" value="true" onclick="noVR(this)" %($Desktop%)>
            <label for="desktop">I don't have a supported headset yet</label>
        </div>

%       if {! isempty $onboarding} {
            <button type="submit" class="btn btn-mango">Next page</button>
%       } {
            <button type="submit" class="btn btn-mango">Save</button>
%       }
    </form>
%   if {! isempty $onboarding} {
        <form id="form" action="" method="POST" accept-charset="utf-8">
            <button type="submit" name="back" value="true" class="btn btn-blueraspberry btn-back">Back</button>
        </form>
%   }
</div>

<style>
    td:last-child {
        width: 65%;
        padding-left: 1em;
    }
</style>

<script type="text/javascript">
    var tagify_gender = new Tagify(document.querySelector('input[name=gender_other]'), {
        whitelist: ["Agender", "Androgynous", "Bigender", "Demiman", "Demiwoman", "Gender Fluid", "Gender Nonconforming", "Gender Questioning", "Gender Variant", "Genderqueer", "Hijra", "Intersex", "Neutrois", "Non-Binary", "Other", "Pangender", "Polygender", "Two-Spirit", "Trans Man", "Trans Person", "Trans Woman", "Transfeminine", "Transgender", "Transgender Man", "Transgender Person", "Transgender Woman", "Transmasculine", "Transsexual", "Transsexual Man", "Transsexual Woman"],
        maxTags: 1,
        skipInvalid: true,
        originalInputValueFormat: valuesArr => valuesArr.map(item => item.value).join(','),
        dropdown: {
            enabled: 0,
            maxItems: 0
        }
    })
    tagify_gender.on('add', gender_onAddTag)
    tagify_gender.on('remove', gender_onRemoveTag)
    function gender_onAddTag() {
        document.querySelector('#other').checked = true
        tagify_gender.dropdown.enabled = false
    }
    function gender_onRemoveTag() {
        tagify_gender.dropdown.enabled = 0
    }

    var tagify_country = new Tagify(document.querySelector('input[name=country]'), {
        delimiters: null,
        templates: {
            tag: function(tagData) {
                try {
                    return `<tag title='${tagData.value}' contenteditable='false' spellcheck="false" class='tagify__tag ${tagData.class ? tagData.class : ""}' ${this.getAttributes(tagData)}>
                                <x title='remove tag' class='tagify__tag__removeBtn'></x>
                                <div>
                                    ${tagData.value ?
                                    `<img onerror="this.style.visibility='hidden'" src='/img/flags/${tagData.value.toLowerCase()}.svg'>` : ''
                                    }
                                    <span class='tagify__tag-text'>${tagData.searchBy}</span>
                                </div>
                            </tag>`
                } catch(err) {}
            },
            dropdownItem: function(tagData) {
                try {
                    return `<div class='tagify__dropdown__item ${tagData.class ? tagData.class : ""}' tagifySuggestionIdx="${tagData.tagifySuggestionIdx}">
                                <img onerror="this.style.visibility = 'hidden'"
                                      src='/img/flags/${tagData.value.toLowerCase()}.svg'>
                                <span>${tagData.searchBy}</span>
                            </div>`
                } catch(err) {}
            }
        },
        enforceWhitelist: true,
        whitelist: [
%           for (country = `{redis graph read 'MATCH (c:country) RETURN c.id ORDER BY c.id'}) {
                { value:'%($country%)', searchBy: new Intl.DisplayNames([], {type: 'region'}).of('%($country%)') },
%           }
        ],
        maxTags: 1,
        skipInvalid: true,
        originalInputValueFormat: valuesArr => valuesArr.map(item => item.value).join(','),
        dropdown: {
            enabled: 0,
            maxItems: 0,
            classname: 'extra-properties'
        }
    })

    function checkGender(checkbox) {
        if (checkbox.checked) {
            [].forEach.call(document.getElementsByClassName('gendercheckbox'), function(el) {
                el.checked = false;
            })
            checkbox.checked = true;
        }
    }
    function checkOther() {
        document.getElementById('other').checked = true;
        checkGender(document.getElementById('other'));
    }
    document.getElementById('gender_other').addEventListener('change', checkOther);

    var tagify_language = new Tagify(document.querySelector('input[name=language]'), {
        delimiters: null,
        templates: {
            tag: function(tagData) {
                try {
                    return `<tag title='${tagData.value}' contenteditable='false' spellcheck="false" class='tagify__tag ${tagData.class ? tagData.class : ""}' ${this.getAttributes(tagData)}>
                                <x title='remove tag' class='tagify__tag__removeBtn'></x>
                                <div>
                                    <span class='tagify__tag-text'>${tagData.searchBy}</span>
                                </div>
                            </tag>`
                } catch(err) {}
            },
            dropdownItem: function(tagData) {
                try {
                    return `<div class='tagify__dropdown__item ${tagData.class ? tagData.class : ""}' tagifySuggestionIdx="${tagData.tagifySuggestionIdx}">
                                <span>${tagData.searchBy}</span>
                            </div>`
                } catch(err) {}
            }
        },
        enforceWhitelist: true,
        whitelist: [
%           for (language = `{redis graph read 'MATCH (l:language) RETURN l.id ORDER BY l.id'}) {
                { value:'%($language%)', searchBy: new Intl.DisplayNames([], {type: 'language'}).of('%($language%)') },
%           }
        ],
        maxTags: 5,
        skipInvalid: true,
        editTags: false,
	transformTag: transformLanguage,
        dropdown: {
            enabled: 0,
            maxItems: 0
        },
        originalInputValueFormat: valuesArr => valuesArr.map(item => item.value).join(',')
    })

    function transformLanguage(tagData) {
        tagData.innerHTML = new Intl.DisplayNames([navigator.language.slice(0, 2)], {type: 'language'}).of(tagData.value);
    }

%   if {! isempty $languages} {
%       for (language = $languages) {
            tagify_language.addTags(new Intl.DisplayNames([navigator.language.slice(0, 2)], {type: 'language'}).of('%($language%)'));
%       }
%   }

    function haveVR(checkbox) {
        if (checkbox.checked) {
            document.getElementById('desktop').checked = false;
        }
    }
    function noVR(checkbox) {
        if (checkbox.checked) {
            [].forEach.call(document.getElementsByClassName('vrcheckbox'), function(el) {
                el.checked = false;
            })
        }
    }
</script>
