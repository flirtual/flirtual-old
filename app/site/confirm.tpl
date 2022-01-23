<div class="box">
%   if {~ $confirm_success true} {
        <h1>Email confirmed</h1>
        <p>Welcome to VRLFP!</p>
%   } {
        <h1>Confirm your email</h1>
%   }

%   if {logged_in} {
        <a href="/" class="btn btn-mango">Next</a>
%   } {
        <a href="/login" class="btn btn-mango">Log in</a>
%   }
</div>
