%{
if {logged_in} {
    (onboarded volume konami optout) = \
        `` \n {redis graph read 'MATCH (u:user {username: '''$logged_user'''})
                                 RETURN NOT exists(u.onboarding), u.volume, u.konami, u.optout'}
}
%}

<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Flirtual</title>

%       if {~ $req_path /onboarding/* || ~ $req_path /nsfw} {
            <link rel="stylesheet" href="/css/tagify.css" media="print" onload="this.media='all'; this.onload=null;">
%       }
        <link rel="stylesheet" href="/css/microtip.css" media="print" onload="this.media='all'; this.onload=null;">
        <link rel="stylesheet" href="/css/swiper.css" media="print" onload="this.media='all'; this.onload=null;">
        <link rel="stylesheet" href="/css/style.css?v=%($dateun%)" onload="this.media='all'; this.onload=null;">
%       if {logged_in} {
            <link rel="stylesheet" href="/dist/converse.min.css" media="screen" onload="this.media='all'; this.onload=null;">
%       }

        <link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png">
        <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png">
        <link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png">
        <link rel="manifest" href="/site.webmanifest">
        <link rel="mask-icon" href="/safari-pinned-tab.svg" color="#25c9d0">
        <meta name="apple-mobile-web-app-title" content="Flirtual">
        <meta name="application-name" content="Flirtual">
        <meta name="msapplication-TileColor" content="#25c9d0">
        <meta name="theme-color" content="#ffffff">

        <meta charset="UTF-8">
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=600, user-scalable=no" />

%       if {~ $req_path /onboarding/* || ~ $req_path /nsfw} {
            <script type="text/javascript" src="/js/tagify.js"></script>
%       }
        <script type="text/javascript" src="/js/swiper.js" defer></script>
        <script>
            (function(src, cb) {
                var s = document.createElement('script');
                s.setAttribute('src', src);
                s.onload = cb;
                (document.head || document.body).appendChild(s);
            })('https://media.flirtu.al/libs/blinkloader/3.x/blinkloader.min.js', function() {
                window.Blinkloader.optimize({
                    "pubkey": "130267e8346d9a7e9bea",
                    "cdnBase": "https://media.flirtu.al",
                    "smartCompression": true,
                    "retina": true,
                    "webp": true,
                    "lazyload": true,
                    "responsive": true,
                    "fadeIn": true,
                    "progressive": true
                });
            })
        </script>
    </head>

    <body>
%       if {~ $onboarded true} {
            <svg id="blob" viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
                <linearGradient id="gradient" gradientTransform="rotate(20)">
                    <stop offset="10%" stop-color="var(--gradient-l)" />
                    <stop offset="90%" stop-color="var(--gradient-r)" />
                </linearGradient>
                <path fill="url(#gradient)" d="M43.2,-68.1C51.4,-61.9,50.4,-42.2,51.5,-27.2C52.7,-12.2,55.9,-1.8,57.9,10.7C59.8,23.3,60.4,38.1,54.4,49.6C48.3,61.1,35.5,69.2,23,68.4C10.4,67.6,-1.8,57.8,-13.7,51.9C-25.6,46.1,-37.2,44.1,-45,37.6C-52.7,31.1,-56.7,19.9,-56.6,9.2C-56.5,-1.5,-52.3,-11.8,-49.3,-24.2C-46.2,-36.6,-44.3,-51.3,-36.3,-57.6C-28.3,-63.8,-14.1,-61.7,1.7,-64.3C17.5,-66.9,35,-74.2,43.2,-68.1Z" transform="translate(100 100)" />
            </svg>

            <nav>
                <a onclick="toggle_nav()"></a>
                <span>☰</span>
                <ul>
                    <li><a href="/">Browse</a></li>
                    <li><a href="/matches">Matches</a></li>
                    <li><a href="/%($logged_user%)">Profile</a></li>
                    <li><a href="/settings">Settings</a></li>
                    <li><a href="/logout">Logout</a></li>
                </ul>
            </nav>
%       }

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
                <a href="https://rovr.atlassian.net/servicedesk/customer/portal/3" target="_blank">
                    <img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiA/Pjxzdmcgdmlld0JveD0iMCAwIDUxMiA1MTIiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PHBhdGggZD0iTTUwMi4zIDE5MC44YzMuOS0zLjEgOS43LS4yIDkuNyA0LjdWNDAwYzAgMjYuNS0yMS41IDQ4LTQ4IDQ4SDQ4Yy0yNi41IDAtNDgtMjEuNS00OC00OFYxOTUuNmMwLTUgNS43LTcuOCA5LjctNC43IDIyLjQgMTcuNCA1Mi4xIDM5LjUgMTU0LjEgMTEzLjYgMjEuMSAxNS40IDU2LjcgNDcuOCA5Mi4yIDQ3LjYgMzUuNy4zIDcyLTMyLjggOTIuMy00Ny42IDEwMi03NC4xIDEzMS42LTk2LjMgMTU0LTExMy43ek0yNTYgMzIwYzIzLjIuNCA1Ni42LTI5LjIgNzMuNC00MS40IDEzMi43LTk2LjMgMTQyLjgtMTA0LjcgMTczLjQtMTI4LjcgNS44LTQuNSA5LjItMTEuNSA5LjItMTguOXYtMTljMC0yNi41LTIxLjUtNDgtNDgtNDhINDhDMjEuNSA2NCAwIDg1LjUgMCAxMTJ2MTljMCA3LjQgMy40IDE0LjMgOS4yIDE4LjkgMzAuNiAyMy45IDQwLjcgMzIuNCAxNzMuNCAxMjguNyAxNi44IDEyLjIgNTAuMiA0MS44IDczLjQgNDEuNHoiLz48L3N2Zz4=" alt="Contact" />
                </a>
                <a href="/discord" target="_blank">
                    <img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiA/Pjxzdmcgdmlld0JveD0iMCAwIDY0MCA1MTIiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PHBhdGggZD0iTTUyNC41MzEsNjkuODM2YTEuNSwxLjUsMCwwLDAtLjc2NC0uN0E0ODUuMDY1LDQ4NS4wNjUsMCwwLDAsNDA0LjA4MSwzMi4wM2ExLjgxNiwxLjgxNiwwLDAsMC0xLjkyMy45MSwzMzcuNDYxLDMzNy40NjEsMCwwLDAtMTQuOSwzMC42LDQ0Ny44NDgsNDQ3Ljg0OCwwLDAsMC0xMzQuNDI2LDAsMzA5LjU0MSwzMDkuNTQxLDAsMCwwLTE1LjEzNS0zMC42LDEuODksMS44OSwwLDAsMC0xLjkyNC0uOTFBNDgzLjY4OSw0ODMuNjg5LDAsMCwwLDExNi4wODUsNjkuMTM3YTEuNzEyLDEuNzEyLDAsMCwwLS43ODguNjc2QzM5LjA2OCwxODMuNjUxLDE4LjE4NiwyOTQuNjksMjguNDMsNDA0LjM1NGEyLjAxNiwyLjAxNiwwLDAsMCwuNzY1LDEuMzc1QTQ4Ny42NjYsNDg3LjY2NiwwLDAsMCwxNzYuMDIsNDc5LjkxOGExLjksMS45LDAsMCwwLDIuMDYzLS42NzZBMzQ4LjIsMzQ4LjIsMCwwLDAsMjA4LjEyLDQzMC40YTEuODYsMS44NiwwLDAsMC0xLjAxOS0yLjU4OCwzMjEuMTczLDMyMS4xNzMsMCwwLDEtNDUuODY4LTIxLjg1MywxLjg4NSwxLjg4NSwwLDAsMS0uMTg1LTMuMTI2YzMuMDgyLTIuMzA5LDYuMTY2LTQuNzExLDkuMTA5LTcuMTM3YTEuODE5LDEuODE5LDAsMCwxLDEuOS0uMjU2Yzk2LjIyOSw0My45MTcsMjAwLjQxLDQzLjkxNywyOTUuNSwwYTEuODEyLDEuODEyLDAsMCwxLDEuOTI0LjIzM2MyLjk0NCwyLjQyNiw2LjAyNyw0Ljg1MSw5LjEzMiw3LjE2YTEuODg0LDEuODg0LDAsMCwxLS4xNjIsMy4xMjYsMzAxLjQwNywzMDEuNDA3LDAsMCwxLTQ1Ljg5LDIxLjgzLDEuODc1LDEuODc1LDAsMCwwLTEsMi42MTEsMzkxLjA1NSwzOTEuMDU1LDAsMCwwLDMwLjAxNCw0OC44MTUsMS44NjQsMS44NjQsMCwwLDAsMi4wNjMuN0E0ODYuMDQ4LDQ4Ni4wNDgsMCwwLDAsNjEwLjcsNDA1LjcyOWExLjg4MiwxLjg4MiwwLDAsMCwuNzY1LTEuMzUyQzYyMy43MjksMjc3LjU5NCw1OTAuOTMzLDE2Ny40NjUsNTI0LjUzMSw2OS44MzZaTTIyMi40OTEsMzM3LjU4Yy0yOC45NzIsMC01Mi44NDQtMjYuNTg3LTUyLjg0NC01OS4yMzlTMTkzLjA1NiwyMTkuMSwyMjIuNDkxLDIxOS4xYzI5LjY2NSwwLDUzLjMwNiwyNi44Miw1Mi44NDMsNTkuMjM5QzI3NS4zMzQsMzEwLjk5MywyNTEuOTI0LDMzNy41OCwyMjIuNDkxLDMzNy41OFptMTk1LjM4LDBjLTI4Ljk3MSwwLTUyLjg0My0yNi41ODctNTIuODQzLTU5LjIzOVMzODguNDM3LDIxOS4xLDQxNy44NzEsMjE5LjFjMjkuNjY3LDAsNTMuMzA3LDI2LjgyLDUyLjg0NCw1OS4yMzlDNDcwLjcxNSwzMTAuOTkzLDQ0Ny41MzgsMzM3LjU4LDQxNy44NzEsMzM3LjU4WiIvPjwvc3ZnPg==" alt="Discord" />
                </a>
                <a href="https://twitter.com/flirtualapp" target="_blank">
                    <img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiA/Pjxzdmcgdmlld0JveD0iMCAwIDUxMiA1MTIiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PHBhdGggZD0iTTQ1OS4zNyAxNTEuNzE2Yy4zMjUgNC41NDguMzI1IDkuMDk3LjMyNSAxMy42NDUgMCAxMzguNzItMTA1LjU4MyAyOTguNTU4LTI5OC41NTggMjk4LjU1OC01OS40NTIgMC0xMTQuNjgtMTcuMjE5LTE2MS4xMzctNDcuMTA2IDguNDQ3Ljk3NCAxNi41NjggMS4yOTkgMjUuMzQgMS4yOTkgNDkuMDU1IDAgOTQuMjEzLTE2LjU2OCAxMzAuMjc0LTQ0LjgzMi00Ni4xMzItLjk3NS04NC43OTItMzEuMTg4LTk4LjExMi03Mi43NzIgNi40OTguOTc0IDEyLjk5NSAxLjYyNCAxOS44MTggMS42MjQgOS40MjEgMCAxOC44NDMtMS4zIDI3LjYxNC0zLjU3My00OC4wODEtOS43NDctODQuMTQzLTUxLjk4LTg0LjE0My0xMDIuOTg1di0xLjI5OWMxMy45NjkgNy43OTcgMzAuMjE0IDEyLjY3IDQ3LjQzMSAxMy4zMTktMjguMjY0LTE4Ljg0My00Ni43ODEtNTEuMDA1LTQ2Ljc4MS04Ny4zOTEgMC0xOS40OTIgNS4xOTctMzcuMzYgMTQuMjk0LTUyLjk1NCA1MS42NTUgNjMuNjc1IDEyOS4zIDEwNS4yNTggMjE2LjM2NSAxMDkuODA3LTEuNjI0LTcuNzk3LTIuNTk5LTE1LjkxOC0yLjU5OS0yNC4wNCAwLTU3LjgyOCA0Ni43ODItMTA0LjkzNCAxMDQuOTM0LTEwNC45MzQgMzAuMjEzIDAgNTcuNTAyIDEyLjY3IDc2LjY3IDMzLjEzNyAyMy43MTUtNC41NDggNDYuNDU2LTEzLjMyIDY2LjU5OS0yNS4zNC03Ljc5OCAyNC4zNjYtMjQuMzY2IDQ0LjgzMy00Ni4xMzIgNTcuODI3IDIxLjExNy0yLjI3MyA0MS41ODQtOC4xMjIgNjAuNDI2LTE2LjI0My0xNC4yOTIgMjAuNzkxLTMyLjE2MSAzOS4zMDgtNTIuNjI4IDU0LjI1M3oiLz48L3N2Zz4=" alt="Twitter" />
                </a><br />

                <a href="/about">About Us</a>
                <a href="/developers">Developers</a><br />

                <a href="/terms">Terms of Service</a>
                <a href="/privacy">Privacy Policy</a>
            </div>

            <div>
                <div class="desktop">
                    Made with &#9829;&#xFE0E; in VR
                    <span class="right">© 2022 ROVR Labs</span>
                </div>
                <div class="mobile center">
                    <span>© 2022 ROVR Labs</span>
                </div>
            </div>
        </footer>

        <script src="/js/main.js?v=%($dateun%)" defer></script>

%       if {~ $konami true} {
            <script>
                window.addEventListener("load", function(event) {
                    daynight();
                }, true);
            </script>
%       }

%       # Converse.js Messaging
%       if {logged_in} {
            <audio id="message_audio">
                <source src="/audio/message.ogg" type="audio/ogg">
                <source src="/audio/message.mp3" type="audio/mpeg">
            </audio>
            <script type="text/javascript" src="/dist/converse.min.js" charset="utf-8"></script>
            <script type="text/javascript">
                converse.initialize({
                    discover_connection_methods: false,
                    websocket_url: 'wss://%($domain%)/ws/',
                    auto_login: true,
                    credentials_url: '/api/auth/xmpp_credentials',
                    loglevel: 'fatal',
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
                            "smileys": ":heart_eyes:",
                            "people": ":thumbsup:",
                            "activity": ":saxophone:",
                            "travel": ":helicopter:",
                            "objects": ":bulb:",
                            "nature": ":cat:",
                            "food": ":pizza:",
                            "symbols": ":yellow_heart:",
                            "flags": ":rainbow_flag:"
                        }
                });

                document.getElementById("message_audio").volume = %($volume%);
            </script>

%       }
%       if {!~ $optout true} {
            <script>
                var _paq = window._paq = window._paq || [];
                _paq.push(['trackPageView']);
                _paq.push(['enableLinkTracking']);
                (function() {
                    var u="//analytics.flirtu.al/";
%                   if {~ $handler_body 'template tpl/profile.tpl'} {
                        _paq.push(['setCustomUrl', '/profile']);
%                   }
                    _paq.push(['setTrackerUrl', u+'matomo.php']);
                    _paq.push(['setSiteId', '1']);
                    var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
                    g.async=true; g.src=u+'matomo.js'; s.parentNode.insertBefore(g,s);
                })();
            </script>
            <noscript><p><img src="//analytics.flirtu.al/matomo.php?idsite=1&amp;rec=1" style="border:0;" alt="" /></p></noscript>
%       }
    </body>
</html>
