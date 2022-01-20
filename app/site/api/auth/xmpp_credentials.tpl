% if {! isempty $logged_user && ! isempty $sessionid} {
{
    "jid": "%($logged_user%)@%($XMPP_HOST%)",
    "password": "%($sessionid%)"
}
% }
