<div class="box">
    <h1>Stats</h1>
    <p>
%{
        users = `{redis graph read 'match (u:user) return count(u)'}
        echo $users registered users
%}
    </p>
    <p>
%{
        notonboarded = `{redis graph read 'match (u:user) where exists(u.onboarding) return count(u)'}
        echo $notonboarded' users not onboarded ('`{x `{/ $notonboarded $users} 100}^'%)'
%}
    <p>
%{
        count = `{redis graph read 'match (u:user) where u.lastlogin <> 1630947341 return count(u)'}
        echo $count' users logged in since 1.2 ('`{x `{/ $count $users} 100}^'%)'
%}
    </p>
    <p>
%{
        waves = `{redis graph read 'match (u:user)-[:WAVED]->(w:user) return count(w)'}
        passes = `{redis graph read 'match (u:user)-[:PASSED]->(w:user) return count(w)'}
        echo $waves' waves / '$passes' passes ('`{x `{/ $waves `{+ $waves $passes}} 100}^'% waved)'
%}
    </p>
    <p>
%{
        friendships = `{redis graph read 'match (u:user)-[:FRIENDS]->(f:user) return count(f)'}
        echo $friendships friendships '('`{x `{/ $friendships `{+ $friendships $waves}} 100}^'% of waves returned)'
%}
    </p>
    <p>
%{
        groups = `{redis graph read 'match (g:group) return count(g)'}
        members = `{redis graph read 'match (u:user)-[:MEMBER]->(g:group) with distinct u return count(u)'}
        echo $groups' groups / '$members' distinct members'
%}
    </p>
    <hr />

    <h2>Query logins</h2>
    <h3>Examples</h3>
    <ul>
        <li>Day: <span style="font-family: monospace">l.date = '2021-01-01'</span></li>
        <li>Week: <span style="font-family: monospace">l.date = '2021-01-01' or l.date = '2021-01-02' or l.date = '2021-01-03' or l.date = '2021-01-04' or l.date = '2021-01-05' or l.date = '2021-01-06' or l.date = '2021-01-07'</span></li>
        <li>Month: <span style="font-family: monospace">l.date starts with '2021-01-'</span></li>
    </ul>
    <form method="POST" accept-charset="utf-8">
        <table>
            <tr>
                <td><input type="checkbox" name="distinct" id="distinct" value="true" checked>
                <label for="distinct" style="display: inline-block">Unique</label></td>
            </tr>
        </table>
        <input type="text" name="login_query" value="%($^p_login_query%)" style="width: calc(100% + 35px); font-family: monospace"><br /><br />
        <button type="submit" class="btn btn-normal">Run</button><br />
    </form>
    <p>
%       if {! isempty $p_login_query} {
%           if {~ $p_distinct true} {
%               redis graph read 'match (u:user)-[:LOGIN]->(l:login) where '$^p_login_query' with distinct u return count(u)'
%           } {
%               redis graph read 'match (u:user)-[:LOGIN]->(l:login) where '$^p_login_query' return count(u)'
%           }
%       }
    </p>
    <hr />

    <h2>Query registrations</h2>
    <h3>Examples</h3>
    <ul>
        <li>Day: <span style="font-family: monospace">u.registered = '2021-01-01'</span></li>
        <li>Week: <span style="font-family: monospace">u.registered = '2021-01-01' or u.registered = '2021-01-02' or u.registered = '2021-01-03' or u.registered = '2021-01-04' or u.registered = '2021-01-05' or u.registered = '2021-01-06' or u.registered = '2021-01-07'</span></li>
        <li>Month: <span style="font-family: monospace">u.registered starts with '2021-01-'</span></li>
    </ul>
    <form method="POST" accept-charset="utf-8">
        <input type="text" name="registration_query" value="%($^p_registration_query%)" style="width: calc(100% + 35px); font-family: monospace"><br /><br />
        <button type="submit" class="btn btn-normal">Run</button><br />
    </form>
    <p>
%       if {! isempty $p_registration_query} {
%           redis graph read 'match (u:user) where '$^p_registration_query' return count(u)'
%       }
    </p>
    <hr />

    <h2>Users</h2>
%   for (u = `{redis graph read 'MATCH (u:user) RETURN u.username'}) {
        <p>
            <a href="/%($u%)" target="_blank">%($u%)</a>:
            Invited by %(`{redis graph read 'MATCH (u:user {username: '''$u'''})-[:REFERRED_BY]->(i:user) RETURN i.username'}%)
            (%(`{redis graph read 'MATCH (u:user {username: '''$u'''})-[:REFERRED_VIA]->(r:referral) RETURN r.id'}%)), registered
            %(`{redis graph read 'MATCH (u:user {username: '''$u'''}) RETURN u.registered'}%)
        </p>
%   }
</div>
