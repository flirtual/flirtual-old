%{
(new vrchat discord steam twitter instagram twitch youtube reddit spotify customurl) = \
    `` \n {redis graph read 'MATCH (u:user {username: '''$logged_user'''})
                             RETURN u.new, u.vrchat, u.discord, u.steam, u.twitter, u.instagram, \
                                    u.twitch, u.youtube, u.reddit, u.spotify, u.customurl'}
bio = `{redis graph read 'MATCH (u:user {username: '''$logged_user'''}) RETURN u.bio'}

for (g = `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})-[:PLAYS]->(g:game) RETURN g.name'}) {
    games = ($games $g)
}

for (var = new vrchat discord steam twitter instagram twitch youtube reddit spotify customurl bio games) {
    if {! isempty $(p_$var)} {
        $var = $(p_$var)
    }
    if {~ $var bio} {
        $var = `{/bin/echo -e $$var | sed 's/\\"/"/g' | bluemonday}
    } {
        $var = `{redis_html $$var}
    }
    if {isempty $$var} {
        $var = ()
    }
}
%}

<link rel="stylesheet" href="/css/quill.css">

<div class="box" style="margin-top: 0">
%   if {! isempty $onboarding} {
        <h1>Almost done!</h1>
        <p>You can edit everything here in your profile settings later!</p>
%   } {
        <h1>Some social info</h1>
%   }

    <form id="form" action="" method="POST" accept-charset="utf-8">
        <label for="bio">Bio (optional)</label>
        <div id="bio" class="quill"></div><br />
        <input type="hidden" id="bio_html" name="bio">

        <label for="games">Fav social VR apps (optional)</label>
        <input name="games" id="games" value="%(`{echo $^games | sed 's/ /,/g; s/_/ /g'}%)">

        <br />
        <input id="new" type="checkbox" name="new" value="true" %(`{if {~ $new true} { echo checked }}%)>
        <label for="new">I'm new to VR</label>
        <br /><br />

        <p>Socials (optional):</p>
        <table>
            <tr>
                <td><label for="vrchat">VRChat:</label></td>
                <td><input type="text" name="vrchat" id="vrchat" placeholder="Username" value="%($vrchat%)"></td>
            </tr>
            <tr>
                <td><label for="discord">Discord:</label></td>
                <td><input type="text" name="discord" id="discord" placeholder="Username#1234" value="%($discord%)"></td>
            </tr>
            <tr>
                <td><label for="steam">Steam:</label></td>
                <td><input type="text" name="steam" id="steam" placeholder="Profile ID" value="%($steam%)"></td>
            </tr>
            <tr>
                <td><label for="twitter">Twitter:</label></td>
                <td><input type="text" name="twitter" id="twitter" placeholder="Username" value="%($twitter%)"></td>
            </tr>
            <tr>
                <td><label for="instagram">Instagram:</label></td>
                <td><input type="text" name="instagram" id="instagram" placeholder="Username" value="%($instagram%)"></td>
            </tr>
            <tr>
                <td><label for="twitch">Twitch:</label></td>
                <td><input type="text" name="twitch" id="twitch" placeholder="Username" value="%($twitch%)"></td>
            </tr>
            <tr>
                <td><label for="youtube">YouTube:</label></td>
                <td><input type="text" name="youtube" id="youtube" placeholder="URL or Channel ID" value="%($youtube%)"></td>
            </tr>
            <tr>
                <td><label for="reddit">Reddit:</label></td>
                <td><input type="text" name="reddit" id="reddit" placeholder="Username" value="%($reddit%)"></td>
            </tr>
            <tr>
                <td><label for="spotify">Spotify:</label></td>
                <td><input type="text" name="spotify" id="spotify" placeholder="Username" value="%($spotify%)"></td>
            </tr>
            <tr>
                <td><label for="customurl">Custom URL:</label></td>
                <td><input type="text" name="customurl" id="customurl" placeholder="https://example.com" value="%($customurl%)"></td>
            </tr>
        </table>
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

<script src="/js/quill.js"></script>
<script type="text/javascript">
    var tagify_games = new Tagify(document.querySelector('input[name=games]'), {
        enforceWhitelist: true,
        whitelist: ['VRChat', %(`{redis graph read 'MATCH (g:game) RETURN g.name ORDER BY g.name' | grep -v VRChat | sed 's/_/ /g; s/^/''/; s/$/'', /'}%)],
        maxTags: 10,
        skipInvalid: true,
        editTags: false,
        dropdown: {
            enabled: 0,
            maxItems: 0
        },
        originalInputValueFormat: valuesArr => valuesArr.map(item => item.value).join(',')
    })

    var quillToolbar = [
        [{ 'header': [3, false] }],
        ['bold', 'italic', 'underline', 'strike'],
        [{ 'color': [] }, { 'background': [] }],
        [{ 'list': 'ordered'}, { 'list': 'bullet' }],
        ['blockquote', 'code-block'],
        [{ 'align': [] }],
        ['link']
    ]
    var quill = new Quill('#bio', {
        modules: {
            toolbar: quillToolbar
        },
        formats: ['header', 'bold', 'italic', 'underline', 'strike', 'color', 'background', 'list', 'blockquote', 'code-block', 'align', 'code', 'script', 'indent', 'direction', 'link'],
        theme: 'snow'
    });

    const bio_html = `%($bio%)`;
    const bio_delta = quill.clipboard.convert(bio_html);
    quill.setContents(bio_delta, 'silent');

    document.getElementById('form').addEventListener('submit', function(e) {
        e.preventDefault();
        document.getElementById('bio_html').value = quill.container.firstChild.innerHTML;
        document.getElementById('form').submit();
    });
</script>
