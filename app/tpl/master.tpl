<!DOCTYPE html>
<html>
    <head>
        <title>VRLFP</title>

%       if {~ $req_path /onboarding/* || ~ $req_path /g/create} {
            <link rel="stylesheet" href="/css/tagify.css" media="print" onload="this.media='all'; this.onload=null;">
%       }
        <link rel="stylesheet" href="/css/style.css?v=%($dateun%)">
%       if {logged_in} {
            <link rel="stylesheet" href="/dist/converse.min.css" media="screen">
            <!--<script type="text/javascript" src="/js/libsignal-protocol.js" charset="utf-8"></script> omemo, not working reliably -->
            <script type="text/javascript" src="/dist/converse.min.js" charset="utf-8"></script>
%       }
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@800&family=Nunito&display=swap" rel="stylesheet">

        <link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png">
        <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png">
        <link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png">
        <link rel="manifest" href="/site.webmanifest">
        <link rel="mask-icon" href="/safari-pinned-tab.svg" color="#25c9d0">
        <meta name="apple-mobile-web-app-title" content="VRLFP">
        <meta name="application-name" content="VRLFP">
        <meta name="msapplication-TileColor" content="#25c9d0">
        <meta name="theme-color" content="#ffffff">

        <meta charset="UTF-8">
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=800, user-scalable=no" />

%       if {~ $req_path /onboarding/*} {
            <script type="text/javascript" src="/js/tagify.js"></script>
%       }
    </head>

%   if {logged_in && ~ `{redis graph read 'MATCH (u:user {username: '''$logged_user'''}) RETURN u.theme'} dark} {
%       css_theme = dark
%   } {
%       css_theme = light
%   }

    <body class="%($css_theme%)">
        <svg id="blob" viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
            <linearGradient id="gradient" gradientTransform="rotate(20)">
                <stop offset="10%" stop-color="#ff9190" />
                <stop offset="90%" stop-color="#eb7295" />
            </linearGradient>
            <path fill="url(#gradient)" d="M43.2,-68.1C51.4,-61.9,50.4,-42.2,51.5,-27.2C52.7,-12.2,55.9,-1.8,57.9,10.7C59.8,23.3,60.4,38.1,54.4,49.6C48.3,61.1,35.5,69.2,23,68.4C10.4,67.6,-1.8,57.8,-13.7,51.9C-25.6,46.1,-37.2,44.1,-45,37.6C-52.7,31.1,-56.7,19.9,-56.6,9.2C-56.5,-1.5,-52.3,-11.8,-49.3,-24.2C-46.2,-36.6,-44.3,-51.3,-36.3,-57.6C-28.3,-63.8,-14.1,-61.7,1.7,-64.3C17.5,-66.9,35,-74.2,43.2,-68.1Z" transform="translate(100 100)" />
        </svg>

        <nav>
            <a onclick="toggle_nav()">
                Menu
            </a>
            <ul>
                <li><a href="/">Browse</a></li>
                <li><a href="/matches">Matches</a></li>
                <li><a href="/%($logged_user%)">Profile</a></li>
                <li><a href="/settings">Settings</a></li>
                <li><a href="/logout">Logout</a></li>
            </ul>
        </nav>

        <main>
%           # Display `throw`n errors
%           if {! isempty $notice} {
                <div class="notice">%($notice%) :(</div>
%           }

%           # Do the thing!
%           $handler_body
        </main>

%       # Footer
        <footer>
            <div class="center">
%               if {logged_in} {
                    <a onclick="fetch('/api/settheme/light'); document.body.classList.remove('dark'); document.body.classList.add('light')" title="Light theme">☀️</a>
                    <a onclick="fetch('/api/settheme/dark'); document.body.classList.remove('light'); document.body.classList.add('dark')" title="Dark theme">🌑</a><br />
%               } {!~ $req_path /} {
                    <a onclick="localStorage.setItem('theme', 'light');  document.body.classList.remove('dark'); document.body.classList.add('light')" title="Light theme">☀️</a>
                    <a onclick="localStorage.setItem('theme', 'dark');  document.body.classList.remove('light'); document.body.classList.add('dark')" title="Dark theme">🌑</a><br />
%               }

                <a href="https://rovr.atlassian.net/servicedesk/customer/portal/3" target="_blank">Contact</a>
                <a href="/discord" target="_blank">Discord</a>
                <a href="https://twitter.com/vrlfp" target="_blank">Twitter</a><br />

                <a href="/about">About</a>
                <a href="/principles">Principles</a>
                <a href="/roadmap">Roadmap</a>
                <a href="/developers">Developers</a><br />

                <a href="/terms">Terms of Service</a>
                <a href="/privacy">Privacy Policy</a>
            </div>

            <div>
                <div class="desktop">
                    Made with ❤️+🥽
                    <span class="right">© 2022 ROVR Labs</span>
                </div>
                <div class="mobile center">
                    <span>© 2022 ROVR Labs</span>
                </div>
            </div>
        </footer>

        <script type="text/javascript" src="/js/main.js?v=%($dateun%)"></script>

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
