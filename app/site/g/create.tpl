<link rel="stylesheet" href="/css/quill.css">

<a href="/g/" class="btn btn-blueraspberry">Back to groups</a><br /><br />

<form action="" method="POST" accept-charset="utf-8" id="form">
    <div class="box">
        <h1>Create a community group</h1>

        <label for="name">Name</label>
        <input type="text" name="name" id="name" required placeholder="My Awesome Group" value="%(`{echo $^p_name | escape_html}%)">

        <label for="url">Group URL</label>
        <div class="inline-label">
            <span>vrlfp.com/g/</span>
            <input type="text" name="url" id="url" required placeholder="awesome" value="%(`{echo $^p_url | escape_html}%)">
        </div>

        <label for="description">Description</label>
        <div id="description" class="quill"></div>
        <input type="hidden" id="description_html" name="description">

        <label for="interests_default">Tags (standard, up to 3)</label>
        <input type="text" name="interests_default" id="interests_default" required value="%(`{echo $^p_interests_default | escape_html}%)">

        <label for="interests_custom">Tags (custom, up to 2, optional)</label>
        <input type="text" name="interests_custom" id="interests_custom" value="%(`{echo $^p_interests_custom | escape_html}%)">

        <label for="discord">Discord invite (optional)</label>
        <input type="text" name="discord" id="discord" placeholder="https://discord.gg/..." value="%(`{echo $^p_discord | escape_html}%)">

        <label>Type</label>
        <select name="type">
            <option value="public">Public (listed in our directory, anyone can join)</option>
            <option value="private">Private (secret invite link)</option>
        </select>

        <button type="submit" class="btn btn-mango">Create group</button>
    </form>
</div>

<script src="/js/quill.js"></script>
<script type="text/javascript">
    var quillToolbar = [
        [{ 'header': [3, false] }],
        ['bold', 'italic', 'underline', 'strike'],
        [{ 'color': [] }, { 'background': [] }],
        [{ 'list': 'ordered'}, { 'list': 'bullet' }],
        ['blockquote', 'code-block'],
        [{ 'align': [] }]
    ]
    var quill = new Quill('#description', {
        modules: {
            toolbar: quillToolbar
        },
        formats: ['header', 'bold', 'italic', 'underline', 'strike', 'color', 'background', 'list', 'blockquote', 'code-block', 'align', 'code', 'script', 'indent', 'direction'],
        theme: 'snow'
    });

    document.getElementById('form').addEventListener('submit', function(e) {
        e.preventDefault();
        document.getElementById('description_html').value = quill.container.firstChild.innerHTML;
        document.getElementById('form').submit();
    });

    var tagify_interests_default = new Tagify(document.querySelector('input[name=interests_default]'), {
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
%           for (tag = `{redis graph read 'MATCH (t:tag)
%                                          WHERE t.category <> ''custom''
%                                          RETURN t.name
%                                          ORDER BY t.name'}) {
                { value:'%($tag%)', searchBy:'%(`{echo $tag | sed 's/____/+/g; s/___/\//g; s/__/-/g; s/_/ /g'}%)' },
%           }
        ],
        maxTags: 3,
        skipInvalid: true,
        originalInputValueFormat: valuesArr => valuesArr.map(item => item.value).join(','),
        dropdown: {
            enabled: 0,
            maxItems: 0,
            classname: 'extra-properties'
        }
    })

    var tagify_interests_custom = new Tagify(document.querySelector('input[name=interests_custom]'), {
        maxTags: 2,
        skipInvalid: true,
        originalInputValueFormat: valuesArr => valuesArr.map(item => item.value).join(','),
        dropdown: {
            enabled: 0,
            maxItems: 0
        }
    })
</script>
