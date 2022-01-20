%{
tags_noncustom = `{redis_html `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})-[:INTERESTED_IN]->(t:tag)
                                                  WHERE NOT t.category = ''custom''
                                                  RETURN t.name'}}
tags_custom = `{redis_html `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})-[:INTERESTED_IN]->(t:tag)
                                               WHERE t.category = ''custom''
                                               RETURN t.name ORDER BY toLower(t.name)'} | sed 's/ /,/g; s/_/ /g'}

for (var = $tags_noncustom) {
    $var = checked
}
%}

<form action="" method="POST" accept-charset="utf-8">
    <div class="box">
        <h1>Choose your profile tags</h1>
        <p>Profile tags let ROVR connect you with new people and events you'll like, and helps other users get to know you!</p>
%       if {! isempty $onboarding} {
            <p>Don't overthink it &ndash; you can update these later.</p>
%       }
    </div>

    <div class="box">
        <h1>Life</h1>
        <p>Important things about you.</p>

        <div class="tags">
%           for (tag = `{redis graph read 'MATCH (t:tag {category: ''life''}) RETURN t.name ORDER BY t.name'}) {
                <input id="%($tag%)" type="checkbox" name="%($tag%)" value="yes" %($$tag%)>
                <label for="%($tag%)">%(`{echo $tag | sed 's/____/+/g; s/___/\//g; s/__/-/g; s/_/ /g'}%)</label>
%           }
        </div>
    </div>

    <div class="box">
        <h1>Creative</h1>
        <p>Beginners, pros, and fans are all welcome!</p>

        <div class="tags">
%           for (tag = `{redis graph read 'MATCH (t:tag {category: ''creation''}) RETURN t.name ORDER BY t.name'}) {
                <input id="%($tag%)" type="checkbox" name="%($tag%)" value="yes" %($$tag%)>
                <label for="%($tag%)">%(`{echo $tag | sed 's/____/+/g; s/___/\//g; s/__/-/g; s/_/ /g'}%)</label>
%           }
        </div>
    </div>

    <div class="box">
        <h1>Genre</h1>
        <p>Where you like to nerd out.</p>

        <div class="tags">
%           for (tag = `{redis graph read 'MATCH (t:tag {category: ''genre''}) RETURN t.name ORDER BY t.name'}) {
                <input id="%($tag%)" type="checkbox" name="%($tag%)" value="yes" %($$tag%)>
                <label for="%($tag%)">%(`{echo $tag | sed 's/____/+/g; s/___/\//g; s/__/-/g; s/_/ /g'}%)</label>
%           }
        </div>
    </div>

    <div class="box">
        <h1>Gaming</h1>
        <p>What are your favorite kinds of games?</p>

        <div class="tags">
%           for (tag = `{redis graph read 'MATCH (t:tag {category: ''gaming''}) RETURN t.name ORDER BY t.name'}) {
                <input id="%($tag%)" type="checkbox" name="%($tag%)" value="yes" %($$tag%)>
                <label for="%($tag%)">%(`{echo $tag | sed 's/____/+/g; s/___/\//g; s/__/-/g; s/_/ /g'}%)</label>
%           }
        </div>
    </div>

    <div class="box">
        <h1>VR Social</h1>
        <p>Things you like doing or want to try in VR.</p>

        <div class="tags">
%           for (tag = `{redis graph read 'MATCH (t:tag {category: ''social''}) RETURN t.name ORDER BY t.name'}) {
                <input id="%($tag%)" type="checkbox" name="%($tag%)" value="yes" %($$tag%)>
                <label for="%($tag%)">%(`{echo $tag | sed 's/____/+/g; s/___/\//g; s/__/-/g; s/_/ /g'}%)</label>
%           }
        </div>
    </div>

    <div class="box">
        <h1>Custom tags</h1>
        <p>Input up to 15 things you love. For example, hobbies, passions, topics you're an expert on, or your favorite games and shows.</p>
        <input name="custom" id="custom" %(`{if {! isempty $tags_custom} { echo 'value="'$^tags_custom'"' }}%)>
        <p>Hit <span class="desktop">"tab" or </span>"enter" to input multiple tags.</p>

%       if {! isempty $onboarding} {
            <button type="submit" name="back" value="true" class="btn btn-blueraspberry btn-back">Back</button>
            <button type="submit" class="btn btn-mango">Next page</button>
%       } {
            <button type="submit" class="btn btn-mango">Save</button>
%       }
    </div>
</form>

<script type="text/javascript">
    var tagify_custom = new Tagify(document.querySelector('input[name=custom]'), {
        originalInputValueFormat: valuesArr => valuesArr.map(item => item.value).join(','),
        maxTags: 15,
        pattern: /^.{0,50}$/
    })
</script>
