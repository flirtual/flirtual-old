%{
(new vrchat discord privacy) = \
    `` \n {redis graph read 'MATCH (u:user {username: '''$logged_user'''})
                             RETURN u.new, u.vrchat, u.discord, u.privacy_socials'}
bio = `{redis graph read 'MATCH (u:user {username: '''$logged_user'''}) RETURN u.bio'}

for (g = `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})-[:PLAYS]->(g:game) RETURN g.name'}) {
    games = ($games $g)
}

for (i = `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})-[:TAGGED]->(i:interest) RETURN i.name'}) {
    interests = ($interests $i)
}

for (var = new vrchat discord bio games interests) {
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
        <h1>Almost done</h1>
        <p>You can edit everything here in your profile settings later!</p>
%   } {
        <h1>Social info</h1>
%   }

    <form id="form" action="" method="POST" accept-charset="utf-8">
        <label for="pfp">Profile pics</label><br /><br />
        <input id="pfp"
               type="hidden"
               role="uploadcare-uploader"
               data-public-key="130267e8346d9a7e9bea"
               data-multiple="true"
               data-images-only="true"
               data-tabs="file camera url facebook"
               data-effects="crop, rotate, mirror, flip, enhance" /><br />

        <div id="pfplist">
%           avatars = `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})-[:AVATAR]->(a:avatar)
%                                         RETURN a.url ORDER BY a.order'}
%           if {! isempty $avatars} {
%               order = 0
%               for (avatar = $avatars) {
                    <div id="pfp_%($order%)">
                        <button type="button" onclick="delete_pfp(%($order%))" class="btn-delete">✖</button>
                        <img data-blink-ops="scale-crop: 150x150; scale-crop-position: smart_faces_points"
                             data-blink-uuid="%($avatar%)" />
                        <input type="hidden" name="pfp_%($order%)" value="%($avatar%)">
                    </div>
%                   ++ order
%               }
%           }
        </div><br />

        <label for="bio">Bio</label>
        <div class="bio_wrapper"><div id="bio" class="quill"></div></div><br />
        <input type="hidden" id="bio_html" name="bio" required>

        <input id="new" type="checkbox" name="new" value="true" %(`{if {~ $new true} { echo checked }}%)>
        <label for="new">I'm new to VR</label><br /><br />

        <label for="games">Fav social VR games (optional)</label>
        <input name="games" id="games" value="%(`{echo $^games | sed 's/ /,/g; s/_/ /g'}%)">

        <label for="interests">Personal tags (optional)</label>
        <input name="interests" id="interests" value="%(`{echo $^interests | sed 's/ /,/g; s/_/ /g'}%)">

        <p style="margin-bottom: 10px">Accounts (optional):</p>
        <table>
            <tr>
                <td><label for="vrchat">VRChat:</label></td>
                <td><input type="text" name="vrchat" id="vrchat" placeholder="Username" value="%(`{echo $vrchat | sed 's/.*\///'}%)"></td>
            </tr>
            <tr>
                <td><label for="discord">Discord:</label></td>
                <td><input type="text" name="discord" id="discord" placeholder="Username#1234" value="%($discord%)"></td>
            </tr>
        </table>

        <label>Privacy: Who can see your linked accounts?</label>
        <select name="privacy">
            <option value="vrlfp" %(`{if {~ $privacy vrlfp} { echo 'selected' }}%)>Anyone on VRLFP</option>
            <option value="friends" %(`{if {~ $privacy friends} { echo 'selected' }}%)>Matches only</option>
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

    uploadcare.registerTab("preview", uploadcareTabEffects)
    UPLOADCARE_LOCALE_TRANSLATIONS = {
        buttons: {
            choose: {
                images: {
                    other: "Choose images"
                }
            }
        }
    }

    const widget = uploadcare.MultipleWidget("[role=uploadcare-uploader]");
    widget.onChange(function (group) {
        group.files().forEach(file => {
            file.done(fileInfo => {
                var url = fileInfo.cdnUrl.split("/").slice(3,-1).join("/");
                var order = document.getElementById("pfplist").children.length;

                var div = document.createElement("div");
                div.setAttribute("id", "pfp_" + order);

                var button = document.createElement("button");
                button.setAttribute("type", "button");
                button.setAttribute("onclick", "delete_pfp(" + order + ")");
                button.setAttribute("class", "btn-delete");
                button.innerHTML = "✖";

                var img = document.createElement("img");
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

    var tagify_games = new Tagify(document.querySelector('input[name=games]'), {
        enforceWhitelist: true,
        whitelist: [
%           for (game = `` \n {redis graph read 'MATCH (g:game)
%                                                RETURN g.name
%                                                ORDER BY g.order, g.name' | sed 's/_/ /g'}) {
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
%           for (interest = `` \n {redis graph read 'MATCH (i:interest {type: ''default''})
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
</script>
