<div class="box">
    <h1>Forgot your password?</h1>

%   if {~ $forgot_success true} {
        <p>Sent! Please check your email for a link to reset your password.</p>
%   } {
        <p>Please enter your email and we'll send along a link to reset your password.</p>

        <form action="" method="POST" accept-charset="utf-8">
            <label for="email">Account email</label>
            <input type="email" name="email" id="email" required placeholder="whomstever@example.com" value="%(`{echo $^p_email | escape_html}%)">

            <button type="submit" class="btn btn-mango">Submit</button>
        </form>
%   }
</div>
