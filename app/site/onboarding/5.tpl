<div class="box">
    <h1>Email confirmation</h1>
    <p>Please check your email for a confirmation link to activate your account. If you don't see it in your inbox, please check your spam folder!</p>

%   if {~ $p_resend yes} {
        <p>Sent! Please check your email for a confirmation link.</p>
%   } {
        <form action="" method="POST" accept-charset="utf-8">
            <button type="submit" name="resend" value="yes" class="btn btn-gradient">Resend email</button>
        </form>
%   }
</div>

<div class="box">
    <h1>No email?</h1>
%   if {~ $update_success true} {
        <p>Success! Your email has been updated and we've sent you a new confirmation link.</p>
        <p>Please <a href="https://vrlfp.atlassian.net/servicedesk/customer/portal/3/group/4/create/46" target="_blank">contact us</a> if you're still having trouble.</p>
%   } {
        <p>Your email is <strong>%(`{redis_html `{redis graph read 'MATCH (u:user {username: '''$logged_user'''}) RETURN u.email'}}%)</strong>. If that's wrong, or if you'd like to try a different email, you can enter a new address below:</p>

        <form action="" method="POST" accept-charset="utf-8">
            <table>
                <tr>
                    <td><label for="email">Email:</label></td>
                    <td style="width: 100%"><input type="email" name="email" id="email" required placeholder="whomstever@example.com" value="%(`{echo $^p_email | escape_html}%)"></td>
                </tr>
            </table>

            <button type="submit" class="btn btn-gradient">Update email</button>
        </form>
%   }
</div>
