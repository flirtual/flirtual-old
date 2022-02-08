%{
if {!~ $^debug true ||
    !~ `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})
                           RETURN u.debugger'} true} {
    return 0
}
%}

<div class="box">
    <h1>Debug</h1>
    <form method="POST" accept-charset="utf-8" name="prompt">
        <input type="text" name="command" value="%($^p_command%)" autofocus style="width: 100%; font-family: monospace">
        <button type="submit" class="btn">Run</button>
    </form>
    
    <pre style="overflow-x: auto">
%       if {! isempty $p_command} {
%           es -xc $p_command >[2=1] | escape_html
%       }
        <hr />
%       env | escape_html
    </pre>
</div>
