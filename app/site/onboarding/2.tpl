%{
(dob gender_woman gender_man privacy_sexuality country privacy_country new) = \
    `` \n {redis graph read 'MATCH (u:user {username: '''$logged_user'''})
                             OPTIONAL MATCH (u)-[:COUNTRY]->(c:country)
                             OPTIONAL MATCH (u)-[:GENDER]->(w:gender {name: ''Woman''})
                             OPTIONAL MATCH (u)-[:GENDER]->(m:gender {name: ''Man''})
                             RETURN u.dob, exists(w), exists(m), u.privacy_sexuality,
                                    c.id, u.privacy_country, u.new'}

genders_other = `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})-[:GENDER]->(g:gender {type: ''nonbinary''})
                                    RETURN g.name ORDER BY g.order'}

sexualities = `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})-[:SEXUALITY]->(s:sexuality)
                                  RETURN s.name ORDER BY s.order'}

languages = `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})-[:KNOWS]->(l:language)
                                RETURN l.id'}

platforms = `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})-[:USES]->(p:platform)
                                RETURN p.name'}

for (g = `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})-[:PLAYS]->(g:game) RETURN g.name'}) {
    games = ($games $g)
}

for (i = `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})-[:TAGGED]->(i:interest) RETURN i.name'}) {
    interests = ($interests $i)
}

for (var = dob gender_woman gender_man privacy_sexuality country privacy_country new genders_other \
           sexualities languages) {
    if {! isempty $(p_$var)} {
        $var = $(p_$var)
    }
    $var = `{redis_html $$var}
    if {isempty $$var} {
        $var = ()
    }
}

if {!~ $dob *-*} {
    dob = `{echo $dob | sed 's/(....)(..)(..)/\1-\2-\3/'}
}
%}

<script src="/js/intlpolyfill.js"></script>

<div class="box" style="margin-top: 0">
    <h1>Basic info</h1>

    <form id="form" action="" method="POST" accept-charset="utf-8">
        <label for="dob">Date of birth (only your age will be visible)</label>
        <input type="date" name="dob" id="dob" min="1900-01-01" autocomplete="bday" placeholder="YYYY-MM-DD" value="%($dob%)">

        <label>Gender</label><br />
        <input type="checkbox" name="gender_man" id="gender_man" value="true" %(`{if {~ $gender_man true} { echo checked }}%)>
        <label for="gender_man">Man</label><br />
        <input type="checkbox" name="gender_woman" id="gender_woman" value="true" style="margin-top: 12px" %(`{if {~ $gender_woman true} { echo checked }}%)>
        <label for="gender_woman">Woman</label><br />
        <table>
            <tr>
                <td style="width: 1px; white-space: nowrap; transform: translateX(-2px)">
                    <input type="checkbox" name="gender_other" id="gender_other" value="true" %(`{if {~ $gender_other true || ! isempty $genders_other} { echo checked }}%)>
                    <label for="gender_other">More:</label>
                </td>
                <td style="width: 100%">
                    <input name="genders_other" id="genders_other" value="%(`{echo $^genders_other | sed 's/ /,/g; s/_/ /g'}%)"></input>
                </td>
            </tr>
        </table>

        <label for="sexuality">Sexuality (optional)</label>
        <input name="sexuality" id="sexuality" value="%(`{echo $^sexualities | sed 's/ /,/g; s/_/ /g'}%)">

        <label>Privacy: Who can see your sexuality?</label>
        <select name="privacy_sexuality">
            <option value="everyone" %(`{if {~ $privacy_sexuality everyone} { echo 'selected' }}%)>Anyone on Flirtual</option>
            <option value="matches" %(`{if {~ $privacy_sexuality matches} { echo 'selected' }}%)>Matches only</option>
            <option value="me" %(`{if {~ $privacy_sexuality me} { echo 'selected' }}%)>Just me</option>
        </select>

        <label for="country">Location (optional)</label>
        <input name="country" id="country" class="countries" value="%($country%)">

        <label>Privacy: Who can see your country?</label>
        <select name="privacy_country">
            <option value="everyone" %(`{if {~ $privacy_country everyone} { echo 'selected' }}%)>Anyone on Flirtual</option>
            <option value="matches" %(`{if {~ $privacy_country matches} { echo 'selected' }}%)>Matches only</option>
            <option value="me" %(`{if {~ $privacy_country me} { echo 'selected' }}%)>Just me</option>
        </select>

        <label for="language">Language</label>
        <input name="language" id="language" required>

        <label for="platform">VR setup</label>
        <input name="platform" id="platform" required>

        <input id="new" type="checkbox" name="new" value="true" %(`{if {~ $new true} { echo checked }}%) style="margin: 15px 75px 30px 4px">
        <label for="new" style="display: inline-block; width: auto; transform: translateY(8px)">I'm new to VR</label><br /><br />

        <label for="games">Fav social VR games</label>
        <input name="games" id="games" required value="%(`{echo $^games | sed 's/ /,/g; s/_/ /g'}%)">

        <label for="interests">Personal interest tags (you can add custom interests too!)</label>
        <input name="interests" id="interests" required value="%(`{if {! isempty $interests} { echo $interests | sed 's/ /,/g; s/_/ /g'}}%)">

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
    td:last-child {
        width: 65%;
        padding-left: 1em;
    }
</style>

<script type="text/javascript">
    var tagify_gender = new Tagify(document.querySelector('input[name=genders_other]'), {
        whitelist: [
%           for (gender = `` \n {redis graph read 'MATCH (g:gender {type: ''nonbinary''})
%                                                  RETURN g.name
%                                                  ORDER BY g.order' | sed 's/_/ /g'}) {
                "%($gender%)",
%           }
        ],
        maxTags: 3,
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
        document.querySelector('#gender_other').checked = true
        tagify_gender.dropdown.enabled = false
    }
    function gender_onRemoveTag() {
        tagify_gender.dropdown.enabled = 0
    }

    var tagify_sexuality = new Tagify(document.querySelector('input[name=sexuality]'), {
        whitelist: [
%           for (sexuality = `` \n {redis graph read 'MATCH (s:sexuality)
%                                                     RETURN s.name
%                                                     ORDER BY s.order' | sed 's/_/ /g'}) {
                "%($sexuality%)",
%           }
        ],
        maxTags: 3,
        skipInvalid: true,
        originalInputValueFormat: valuesArr => valuesArr.map(item => item.value).join(','),
        dropdown: {
            enabled: 0,
            maxItems: 0
        }
    })

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

    var tagify_platform = new Tagify(document.querySelector('input[name=platform]'), {
        delimiters: null,
        templates: {
            tag: function(tagData) {
                try {
                    return `<tag title='${tagData.value}' contenteditable='false' spellcheck="false" class='tagify__tag ${tagData.class ? tagData.class : ""}' ${this.getAttributes(tagData)}>
                                <x title='remove tag' class='tagify__tag__removeBtn'></x>
                                <div>
                                    <span class='tagify__tag-text'>${tagData.value.replace(/_/g, ' ')}</span>
                                </div>
                            </tag>`
                } catch(err) {}
            },
            dropdownItem: function(tagData) {
                try {
                    return `<div class='tagify__dropdown__item ${tagData.class ? tagData.class : ""}' tagifySuggestionIdx="${tagData.tagifySuggestionIdx}">
                                <span>${tagData.display}</span>
                            </div>`
                } catch(err) {}
            }
        },
        enforceWhitelist: true,
        whitelist: [
            { value:'Meta_Quest', display: 'Meta Quest' },
            { value:'Oculus_Link', display: 'Meta Quest with Link' },
            { value:'Oculus_Rift', display: 'Oculus Rift (S)' },
            { value:'SteamVR', display: 'SteamVR (Index, Vive, Pimax, etc.)' },
            { value:'Windows_Mixed_Reality', display: 'Windows Mixed Reality (Reverb, Odyssey,etc.)' },
            { value:'PlayStation_VR', display: 'PlayStation VR' },
            { value:'Mobile_VR', display: 'Mobile VR (Go, Gear VR, Cardboard, Daydream, etc.)' },
            { value:'Desktop', display: 'I don\'t have a headset yet (desktop user)' }
        ],
        maxTags: 5,
        skipInvalid: true,
        editTags: false,
        dropdown: {
            enabled: 0,
            maxItems: 0
        },
        originalInputValueFormat: valuesArr => valuesArr.map(item => item.value).join(',')
    })

%   if {! isempty $platforms} {
%       for (platform = $platforms) {
            tagify_platform.addTags("%($platform%)");
%       }
%   }

    var tagify_games = new Tagify(document.querySelector('input[name=games]'), {
        enforceWhitelist: true,
        whitelist: [
%           for (game = `` \n {redis graph read 'MATCH (g:game)
%                                                OPTIONAL MATCH (u:user)-[:PLAYS]->(g)
%                                                RETURN g.name
%                                                ORDER BY count(u) desc, g.name' | sed 's/_/ /g'}) {
                "%($game%)",
%           }
        ],
        maxTags: 5,
        skipInvalid: true,
        editTags: false,
        dropdown: {
            enabled: 0,
            maxItems: 0
        },
        originalInputValueFormat: valuesArr => valuesArr.map(item => item.value).join(',')
    })

    var tagify_interests = new Tagify(document.querySelector('input[name=interests]'), {
        enforceWhitelist: false,
        whitelist: [
%           for (interest = `` \n {redis graph read 'MATCH (i:interest)
%                                                    WHERE i.type = ''default'' OR
%                                                          i.type = ''strong''
%                                                    RETURN i.name
%                                                    ORDER BY i.name' | sed 's/_/ /g'}) {
                "%($interest%)",
%           }
        ],
        maxTags: 5,
        skipInvalid: true,
        editTags: false,
        dropdown: {
            enabled: 0,
            maxItems: 0
        },
        originalInputValueFormat: valuesArr => valuesArr.map(item => item.value).join(',')
    })
</script>
