<div class="box">
    <h1>Reset your password</h1>

%   if {~ $reset_success true} {
        <p>Your password has been reset successfully!</p>
        <a href="/login" class="btn">Log in</a>
%   } {~ `^{redis graph read 'MATCH (u:user)-[:RESET]->(r:reset {id: '''`^{echo $q_id | escape_redis}^'''}) RETURN exists(r)'} true} {
        <form action="" method="POST" accept-charset="utf-8">
            <label for="username">Username<small>(or email)</small></label>
            <input type="text" name="username" id="username" required placeholder="vrlfpfan42" value="%(`{echo $^p_username | escape_html}%)">

            <label for="password">New password</label>
            <input type="password" name="password" id="password" required placeholder="••••••••••••••••">

            <button type="submit" class="btn btn-gradient">Reset</button>
        </form>
%   }
</div>
