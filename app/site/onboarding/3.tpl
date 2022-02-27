%{
(displayname vrchat discord privacy) = \
    `` \n {redis graph read 'MATCH (u:user {username: '''$logged_user'''})
                             RETURN u.displayname, u.vrchat, u.discord, u.privacy_socials'}
bio = `{redis graph read 'MATCH (u:user {username: '''$logged_user'''}) RETURN u.bio'}

for (var = displayname vrchat discord privacy bio) {
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
    <h1>Profile</h1>

    <form id="form" action="" method="POST" accept-charset="utf-8">
        <label for="displayname">Display name</label>
        <input type="text" name="displayname" id="displayname" value="%($displayname%)">
        <p class="help_text">This is how you'll appear around Flirtual. Your display name can contain special characters and doesn't need to be unique. Your profile link (%($domain/$logged_user%)) will still use your username.</p>

        <label for="pfp">Profile pics</label><br /><br />
        <input id="pfp"
               type="hidden"
               role="uploadcare-uploader"
               data-public-key="130267e8346d9a7e9bea"
               data-cdn-base="https://media.flirtu.al"
               data-multiple="true"
               data-images-only="true"
               data-tabs="file url facebook"
               data-effects="crop, rotate, mirror, flip, enhance" /><br />

        <div id="pfplist">
%           avatars = `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})-[:AVATAR]->(a:avatar)
%                                         WHERE NOT a.url = ''e8212f93-af6f-4a2c-ac11-cb328bbc4aa4''
%                                         RETURN a.url ORDER BY a.order LIMIT 15'}
%           if {! isempty $avatars} {
%               order = 0
%               for (avatar = $avatars) {
                    <div id="pfp_%($order%)">
                        <button type="button" onclick="delete_pfp(%($order%))" class="btn-delete">✖</button>
                        <img width="150" height="150"
                             data-blink-ops="scale-crop: 150x150; scale-crop-position: smart_faces_points"
                             data-blink-uuid="%($avatar%)" />
                        <input type="hidden" name="pfp_%($order%)" value="%($avatar%)">
                    </div>
%                   ++ order
%               }
%           }
        </div><br />

        <label for="bio">Bio</label><br />
        <span>Need some inspiration?</span>
        <a onclick="bioPrompt()" class="btn btn-gradient btn-small" style="padding: 6px 12px 7px 39px; transform: translateY(9px) scale(0.85)">
            <img style="position: absolute; width: 23px; height: 23px; margin: -1px 0 0 -30px; background: var(--white); mask-image: url('data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiA/Pjxzdmcgdmlld0JveD0iMCAwIDUxMiA1MTIiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PHBhdGggZD0iTTQ0MC44OCwxMjkuMzcsMjg4LjE2LDQwLjYyYTY0LjE0LDY0LjE0LDAsMCwwLTY0LjMzLDBMNzEuMTIsMTI5LjM3YTQsNCwwLDAsMCwwLDYuOUwyNTQsMjQzLjg1YTQsNCwwLDAsMCw0LjA2LDBMNDQwLjksMTM2LjI3QTQsNCwwLDAsMCw0NDAuODgsMTI5LjM3Wk0yNTYsMTUyYy0xMy4yNSwwLTI0LTcuMTYtMjQtMTZzMTAuNzUtMTYsMjQtMTYsMjQsNy4xNiwyNCwxNlMyNjkuMjUsMTUyLDI1NiwxNTJaIi8+PHBhdGggZD0iTTIzOCwyNzAuODEsNTQsMTYzLjQ4YTQsNCwwLDAsMC02LDMuNDZWMzQwLjg2YTQ4LDQ4LDAsMCwwLDIzLjg0LDQxLjM5TDIzNCw0NzkuNDhhNCw0LDAsMCwwLDYtMy40NlYyNzQuMjdBNCw0LDAsMCwwLDIzOCwyNzAuODFaTTk2LDM2OGMtOC44NCwwLTE2LTEwLjc1LTE2LTI0czcuMTYtMjQsMTYtMjQsMTYsMTAuNzUsMTYsMjRTMTA0Ljg0LDM2OCw5NiwzNjhabTk2LTMyYy04Ljg0LDAtMTYtMTAuNzUtMTYtMjRzNy4xNi0yNCwxNi0yNCwxNiwxMC43NSwxNiwyNFMyMDAuODQsMzM2LDE5MiwzMzZaIi8+PHBhdGggZD0iTTQ1OCwxNjMuNTEsMjc0LDI3MS41NmE0LDQsMCwwLDAtMiwzLjQ1VjQ3NmE0LDQsMCwwLDAsNiwzLjQ2bDE2Mi4xNS05Ny4yM0E0OCw0OCwwLDAsMCw0NjQsMzQwLjg2VjE2N0E0LDQsMCwwLDAsNDU4LDE2My41MVpNMzIwLDQyNGMtOC44NCwwLTE2LTEwLjc1LTE2LTI0czcuMTYtMjQsMTYtMjQsMTYsMTAuNzUsMTYsMjRTMzI4Ljg0LDQyNCwzMjAsNDI0Wm0wLTg4Yy04Ljg0LDAtMTYtMTAuNzUtMTYtMjRzNy4xNi0yNCwxNi0yNCwxNiwxMC43NSwxNiwyNFMzMjguODQsMzM2LDMyMCwzMzZabTk2LDMyYy04Ljg0LDAtMTYtMTAuNzUtMTYtMjRzNy4xNi0yNCwxNi0yNCwxNiwxMC43NSwxNiwyNFM0MjQuODQsMzY4LDQxNiwzNjhabTAtODhjLTguODQsMC0xNi0xMC43NS0xNi0yNHM3LjE2LTI0LDE2LTI0LDE2LDEwLjc1LDE2LDI0UzQyNC44NCwyODAsNDE2LDI4MFoiLz48L3N2Zz4='); -webkit-mask-image: url('data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiA/Pjxzdmcgdmlld0JveD0iMCAwIDUxMiA1MTIiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PHBhdGggZD0iTTQ0MC44OCwxMjkuMzcsMjg4LjE2LDQwLjYyYTY0LjE0LDY0LjE0LDAsMCwwLTY0LjMzLDBMNzEuMTIsMTI5LjM3YTQsNCwwLDAsMCwwLDYuOUwyNTQsMjQzLjg1YTQsNCwwLDAsMCw0LjA2LDBMNDQwLjksMTM2LjI3QTQsNCwwLDAsMCw0NDAuODgsMTI5LjM3Wk0yNTYsMTUyYy0xMy4yNSwwLTI0LTcuMTYtMjQtMTZzMTAuNzUtMTYsMjQtMTYsMjQsNy4xNiwyNCwxNlMyNjkuMjUsMTUyLDI1NiwxNTJaIi8+PHBhdGggZD0iTTIzOCwyNzAuODEsNTQsMTYzLjQ4YTQsNCwwLDAsMC02LDMuNDZWMzQwLjg2YTQ4LDQ4LDAsMCwwLDIzLjg0LDQxLjM5TDIzNCw0NzkuNDhhNCw0LDAsMCwwLDYtMy40NlYyNzQuMjdBNCw0LDAsMCwwLDIzOCwyNzAuODFaTTk2LDM2OGMtOC44NCwwLTE2LTEwLjc1LTE2LTI0czcuMTYtMjQsMTYtMjQsMTYsMTAuNzUsMTYsMjRTMTA0Ljg0LDM2OCw5NiwzNjhabTk2LTMyYy04Ljg0LDAtMTYtMTAuNzUtMTYtMjRzNy4xNi0yNCwxNi0yNCwxNiwxMC43NSwxNiwyNFMyMDAuODQsMzM2LDE5MiwzMzZaIi8+PHBhdGggZD0iTTQ1OCwxNjMuNTEsMjc0LDI3MS41NmE0LDQsMCwwLDAtMiwzLjQ1VjQ3NmE0LDQsMCwwLDAsNiwzLjQ2bDE2Mi4xNS05Ny4yM0E0OCw0OCwwLDAsMCw0NjQsMzQwLjg2VjE2N0E0LDQsMCwwLDAsNDU4LDE2My41MVpNMzIwLDQyNGMtOC44NCwwLTE2LTEwLjc1LTE2LTI0czcuMTYtMjQsMTYtMjQsMTYsMTAuNzUsMTYsMjRTMzI4Ljg0LDQyNCwzMjAsNDI0Wm0wLTg4Yy04Ljg0LDAtMTYtMTAuNzUtMTYtMjRzNy4xNi0yNCwxNi0yNCwxNiwxMC43NSwxNiwyNFMzMjguODQsMzM2LDMyMCwzMzZabTk2LDMyYy04Ljg0LDAtMTYtMTAuNzUtMTYtMjRzNy4xNi0yNCwxNi0yNCwxNiwxMC43NSwxNiwyNFM0MjQuODQsMzY4LDQxNiwzNjhabTAtODhjLTguODQsMC0xNi0xMC43NS0xNi0yNHM3LjE2LTI0LDE2LTI0LDE2LDEwLjc1LDE2LDI0UzQyNC44NCwyODAsNDE2LDI4MFoiLz48L3N2Zz4=')">
            Try a prompt
        </a>
        <div class="bio_wrapper"><div id="bio" class="quill"></div></div>
        <input type="hidden" id="bio_html" name="bio" required>

        <p style="margin: 40px 0 10px 0">Accounts (optional):</p>
        <table>
            <tr>
                <td><label for="vrchat" style="font-size: 115%">VRChat:</label></td>
                <td><input type="text" name="vrchat" id="vrchat" placeholder="Username" value="%(`{echo $vrchat | sed 's/.*\///' | urldecode}%)"></td>
            </tr>
            <tr>
                <td><label for="discord" style="font-size: 115%">Discord:</label></td>
                <td><input type="text" name="discord" id="discord" placeholder="Username#1234" value="%($discord%)"></td>
            </tr>
        </table>

        <label>Privacy: Who can see your linked accounts?</label>
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
    td:last-child {
        width: 100%;
        padding-left: 1em;
    }
</style>

<script src="https://ucarecdn.com/libs/widget/3.x/uploadcare.full.min.js"></script>
<script src="https://ucarecdn.com/libs/widget-tab-effects/1.x/uploadcare.tab-effects.lang.en.min.js"></script>
<script src="/js/sortable.js"></script>
<script src="/js/quill.js"></script>
<script type="text/javascript">
    Array.from(document.getElementById("pfplist").childNodes).forEach((node) => {
        if (node.nodeType === 3) {
            node.remove();
        }
    });

    uploadcare.registerTab("preview", uploadcareTabEffects);

    const widget = uploadcare.MultipleWidget("[role=uploadcare-uploader]");

    widget.validators.push(function(fileInfo) {
        if (fileInfo.size !== null && fileInfo.size > 10 * 1024 * 1024) {
            throw new Error("fileMaximumSize");
        }
    });

    widget.onChange(function(group) {
        group.files().forEach(file => {
            file.done(fileInfo => {
                var uuid = fileInfo.cdnUrl.split("/")[3];
                var url = fileInfo.cdnUrl.split("/").slice(3,-1).join("/");
                var order = document.getElementById("pfplist").children.length;

                if (!document.querySelector('[src*="' + uuid + '"]') && order < 15) {
                    var div = document.createElement("div");
                    div.setAttribute("id", "pfp_" + order);

                    var button = document.createElement("button");
                    button.setAttribute("type", "button");
                    button.setAttribute("onclick", "delete_pfp(" + order + ")");
                    button.setAttribute("class", "btn-delete");
                    button.innerHTML = "✖";

                    var img = document.createElement("img");
                    img.setAttribute("width", 150);
                    img.setAttribute("height", 150);
                    img.setAttribute("data-blink-ops", "scale-crop: 150x150; scale-crop-position: smart_faces_points");
                    img.setAttribute("data-blink-uuid", url);

                    var input = document.createElement("input");
                    input.setAttribute("type", "hidden");
                    input.setAttribute("name", "pfp_" + order);
                    input.setAttribute("value", url);

                    div.appendChild(button);
                    div.appendChild(img);
                    div.appendChild(input);
                    document.getElementById("pfplist").appendChild(div);
                }
            });
        });
    });

    var sortable = new Sortable(document.getElementById("pfplist"), {
        draggable: "div",
        animation: 150,
        easing: "cubic-bezier(1, 0, 0, 1)",
        onEnd: function(event) {
            var first = Math.min(event.oldDraggableIndex, event.newDraggableIndex);
            var second = Math.max(event.oldDraggableIndex, event.newDraggableIndex);
            for (var i = first; i <= second; i++) {
                var order = document.getElementById("pfplist").children[i].children[2];
                order.name = "pfp_" + i;
            }
        }
    });

    function delete_pfp(order) {
        document.querySelector("#pfp_" + order).remove();
    }

    var quillToolbar = [
        [{ 'header': [3, false] }],
        ['bold', 'italic', 'underline', 'strike'],
        [{ 'color': [] }, { 'background': [] }],
        [{ 'list': 'ordered'}, { 'list': 'bullet' }],
        ['blockquote', 'code-block'],
        [{ 'align': [] }]
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

    function bioPrompt() {
        const prompts = [
            "What I'm up to these days",
            "I nerd out on",
            "Never have I ever",
            "If I had to eat one food for the rest of my life, it would be",
            "I think a lot about",
            "Three things I can't live without",
            "Unpopular opinion, but",
            "The secret to getting to know me is",
            "My favorite game ever is",
            "Me as a haiku",
            "My favorite VRChat world"
        ];
        var prompt = prompts[Math.floor(Math.random() * prompts.length)];

        quill.insertText(quill.getLength() - 1, "\n\n");
        quill.clipboard.dangerouslyPasteHTML(quill.getLength() - 1, "<h3>" + prompt + ":</h3>");
    }
</script>
