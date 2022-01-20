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
        <table>
            <tr>
                <td><input type="text" name="command" value="%($^p_command%)" autofocus style="width: calc(100% + 35px); font-family: monospace"></td>
                <td><button type="submit" class="btn btn-mango" style="transform: rotate(-12deg) translate(54px, 29px)">Run</button><br /></td>
            </tr>
        </table>
    </form>
    
    <pre style="overflow-x: auto">
%       if {! isempty $p_command} {
%           es -xc $p_command >[2=1] | escape_html
%       }
        <hr />
%       env | escape_html
    </pre>
</div>
