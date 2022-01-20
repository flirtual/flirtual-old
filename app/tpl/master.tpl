<!DOCTYPE html>
<html>
    <head>
        <title>ROVR</title>

%       if {~ $req_path /onboarding/* || ~ $req_path /g/create} {
            <link rel="stylesheet" href="/css/tagify.css" media="print" onload="this.media='all'; this.onload=null;">
%       }
        <link rel="stylesheet" href="/css/style.css">
%       if {logged_in} {
            <link rel="stylesheet" href="/dist/converse.min.css" media="screen">
            <!--<script type="text/javascript" src="/js/libsignal-protocol.js" charset="utf-8"></script> omemo, not working reliably -->
            <script type="text/javascript" src="/dist/converse.min.js" charset="utf-8"></script>
%       }
        <link rel="stylesheet" href="https://use.typekit.net/auy6elu.css" media="print" onload="this.media='all'; this.onload=null;">

        <link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png">
        <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png">
        <link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png">
        <link rel="manifest" href="/site.webmanifest">
        <link rel="mask-icon" href="/safari-pinned-tab.svg" color="#25c9d0">
        <meta name="apple-mobile-web-app-title" content="ROVR">
        <meta name="application-name" content="ROVR">
        <meta name="msapplication-TileColor" content="#25c9d0">
        <meta name="theme-color" content="#ffffff">

        <meta charset="UTF-8">
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=800, user-scalable=no" />

%       if {~ $req_path /onboarding/* || ~ $req_path /g/create} {
            <script type="text/javascript" src="/js/tagify.js"></script>
%       }
    </head>

%   if {logged_in && ~ `{redis graph read 'MATCH (u:user {username: '''$logged_user'''}) RETURN u.theme'} dark} {
%       css_theme = dark
%   } {
%       css_theme = light
%   }

    <body class="%($css_theme%)">
        <div class="page">
%           if {logged_in && isempty $onboarding} {
%               # Top-left menu button
                <span class="menu_toggle" onclick="toggle_shazam()">
                    <div class="menu_open"></div>
                    <div class="menu_close"></div>
                </span>
                <span class="clickme">Click me!</span>

%               notificationcount = `{redis graph read 'MATCH (a:user)-[w:WAVED]->(b:user {username: '''$logged_user'''})
%                                                       WHERE NOT exists(a.onboarding) AND
%                                                             NOT (b)-[:PASSED]->(a)
%                                                       RETURN count(a)'}
%               if {!isempty $notificationcount} {
                    <span id="notificationcount">%($notificationcount%)</span>
%               }

%               # Friend search, add, chat expand... yet unimplemented
                <!--<div class="menu_actions">
                    <a href="#"><i class="icon fa fa-search fa-2x"></i></a>
                    <a href="#"><i class="icon fa fa-user-plus fa-2x"></i></a>
                    <a href="#"><i class="icon fa fa-expand-alt fa-2x"></i></a>
                </div>-->

%               # Friends list
                <ul class="menu_items">
%{
                friends = `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})-[r:FRIENDS]-(f:user)
                                              RETURN f.username ORDER BY id(r) DESC'}
                friends_displaynames = `` \n {redis graph read 'MATCH (u:user {username: '''$logged_user'''})-[r:FRIENDS]-(f:user)
                                                                RETURN f.displayname ORDER BY id(r) DESC'}
                friends_avatars = `` \n {redis graph read 'MATCH (u:user {username: '''$logged_user'''})-[r:FRIENDS]-(f:user)
                                                           RETURN f.avatar ORDER BY id(r) DESC'}

                if {isempty $friends} {
                    echo '<a href="#">
                              <img src="/img/avatars/64/defaults/01.png" />
                              <span class="menu_text" style="margin: 8px" title="Add friends to fill this list">Add friends to fill this list</span>
                          </a>'
                } {
                    for (friend = $friends; displayname = $friends_displaynames; avatar = $friends_avatars) {
                        echo '<a href="#converse/chat?jid='$friend'@'$XMPP_HOST'" class="btn-msg" style="display: inline-block; margin-top: 8px; margin-bottom: 0"><img src="/img/avatars/64/'$avatar'.png" style="transform: translateY(-7px) scale(1.7)" /><img src="/img/msg.png" style="position: absolute; transform: scale(0.7) translate(-25px, -40px)" /></a>'
                        echo '<a href="/'$friend'" style="display: inline-block"><span class="menu_text" style="top: -34px; left: 28px">'`^{redis_html $displayname}'</span></a><br />'
                    }
                }
%}
                </ul>

%               # User icon
                <div class="menu_self">
                    <a onclick="toggle_user_menu()">
                        <img src="/img/avatars/64/%(`{redis graph read 'MATCH (u:user {username: '''$logged_user'''}) RETURN u.avatar'}%).png" />
                        <span>%($logged_user%)</span>
                    </a>
                </div>

%               # User menu
                <div class="user_menu invisible">
                    <a href="/%($logged_user%)">Profile</a>
                    <a id="notificationbtn" href="/notifications">Notifications</a>
                    <a href="/settings">Settings</a>
%                   if {~ `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})
%                                             RETURN u.admin'} true} {
                        <a href="/stats">Stats</a>
                        <a href="/managegames">Manage games</a>
%                   }
%                   if {~ `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})
%                                             RETURN u.debugger'} true} {
                        <a href="/debug">Debug</a>
%                   }
                    <a href="/logout">Logout</a>
                </div>
%           }

            <main class="content" onclick="hide_shazam()">
                <div class="content_inner">
%{
                    if {logged_in || !~ $req_path /} {
                        echo '<div class="container">'
                    }

                    # Display `throw`n errors
                    if {! isempty $notice} {
                        echo '<div class="notice">'$notice' :(</div>'
                    }

                    # Do the thing!
                    $handler_body

                    # Top-right button
                    if {logged_in} {
                        if {~ $req_path /} {
                            echo '<a href="/'$logged_user'" id="home">Profile</a>'
                        } {isempty $onboarding} {
                            echo '<a href="/" id="home">Home</a>'
                        }
                    } {
                        if {~ $req_path /login} {
                            echo '<a href="/" id="home">Home</a>'
                        } {~ $req_path /register} {
                            echo '<a href="/login" id="home">Login</a>'
                        } {!~ $req_path /} {
                            echo '<a href="/login?redirect='$req_path'" id="home">Login</a>'
                        }
                    }

                    # Jira SD button
                    echo '<a href="https://rovr.atlassian.net/servicedesk/customer/portal/3/group/4/create/45" target="_blank" id="feedback">Feedback</a>'

                    if {logged_in || !~ $req_path /} {
                        echo '</div>'
                    }
%}

%                   # Footer
                    <footer id="footer">
                        <div class="center">
%                           if {logged_in} {
                                <a onclick="fetch('/api/settheme/light'); document.body.classList.remove('dark'); document.body.classList.add('light')" title="Light theme">☀️</a>
                                <a onclick="fetch('/api/settheme/dark'); document.body.classList.remove('light'); document.body.classList.add('dark')" title="Dark theme">🌑</a><br />
%                           } {!~ $req_path /} {
                                <a onclick="localStorage.setItem('theme', 'light');  document.body.classList.remove('dark'); document.body.classList.add('light')" title="Light theme">☀️</a>
                                <a onclick="localStorage.setItem('theme', 'dark');  document.body.classList.remove('light'); document.body.classList.add('dark')" title="Dark theme">🌑</a><br />
%                           }

                            <a href="https://rovr.atlassian.net/servicedesk/customer/portal/3" target="_blank">Contact</a>
                            <a href="/discord" target="_blank">Discord</a>
                            <a href="https://twitter.com/ROVRofficial" target="_blank">Twitter</a><br />

                            <a href="/about">About</a>
                            <a href="/principles">Principles</a>
                            <a href="/roadmap">Roadmap</a>
                            <a href="/developers">Developers</a><br />

                            <a href="/terms">Terms of Service</a>
                            <a href="/privacy">Privacy Policy</a>
                        </div>

                        <div>
                            <div class="desktop">
                                Made with ❤️+🍁+🥽 in Canada
                                <span class="right">© 2022 ROVR Labs</span>
                            </div>
                            <div class="mobile center">
                                <span>© 2022 ROVR Labs</span>
                            </div>
                        </div>
                    </footer>
                </div>
            </main>
        </div>

        <script type="text/javascript" src="/js/main.js"></script>

%       if {!logged_in && !~ $req_path /} {
            <script type="text/javascript">
                if (localStorage.getItem("theme") == "light") {
                    document.body.classList.remove("dark");
                    document.body.classList.add("light");
                } else if (localStorage.getItem("theme") == "dark") {
                    document.body.classList.remove("light");
                    document.body.classList.add("dark");
                }
            </script>
%       }

%       # Converse.js Messaging
%       if {logged_in} {
            <audio id="message_audio">
                <source src="/audio/message.ogg" type="audio/ogg">
                <source src="/audio/message.mp3" type="audio/mpeg">
            </audio>
            <script type="text/javascript">
                converse.initialize({
                    discover_connection_methods: false,
                    websocket_url: 'wss://%($domain%)/ws/',
                    auto_login: true,
                    credentials_url: '/api/auth/xmpp_credentials',
                    loglevel: 'warn',
                    default_domain: '%($XMPP_HOST%)',
                    enable_smacks: true,
                    allow_adhoc_commands: false,
                    allow_bookmarks: false,
                    allow_contact_removal: false,
                    allow_contact_requests: false,
                    allow_logout: false,
                    allow_registration: false,
                    allow_user_trust_override: false,
                    autocomplete_add_contact: false,
                    auto_reconnect: true,
                    auto_register_muc_nickname: true,
                    auto_join_on_invite: true,
                    clear_messages_on_reconnection: false,
                    locked_domain: '%($XMPP_HOST%)',
                    locked_muc_domain: 'hidden',
                    muc_domain: '%($XMPP_HOST%)',
                    muc_hats: [],
                    message_archiving: 'always',
                    message_limit: 2000,
                    muc_show_info_messages: [],
                    notification_icon: '/img/notification.png',
                    notify_nicknames_without_references: true,
                    play_sounds: true,
                    roster_groups: false,
                    show_client_info: false,
                    show_controlbox_by_default: false,
                    show_retraction_warning: false,
                    time_format: 'hh:mm a',
                    use_system_emojis: true,
                    emoji_categories:
                        {
                            "smileys": ":smiley:",
                            "people": ":thumbsup:",
                            "activity": ":soccer:",
                            "travel": ":red_car:",
                            "objects": ":bulb:",
                            "nature": ":maple_leaf:",
                            "food": ":pizza:",
                            "symbols": ":yellow_heart:",
                            "flags": ":rainbow_flag:"
                        }
                });

                document.getElementById("message_audio").volume = %(`{redis graph read 'MATCH (u:user {username: '''$logged_user'''}) RETURN u.volume'}%);
            </script>
%       }
    </body>
</html>
