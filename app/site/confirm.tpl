<div class="box">
%   if {~ $confirm_success true} {
        <h1>Confirmed</h1>
        <p>Welcome to Flirtual!</p>
%   } {
        <h1>Email confirmation</h1>
%   }

%   if {logged_in} {
        <a href="/" class="btn btn-gradient">Next</a>
%   } {
        <a href="/login" class="btn btn-gradient">Log in</a>
%   }
</div>
