<!DOCTYPE html>
<html lang="en">
  <head>
        <title>Flirtual</title>
        <meta name="description" content="Flirtual is the First VR Dating App. Join thousands for dates in Virtual Reality. We support VR dates in VR apps like VRChat. Formerly VRLFP.">

        <link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png?v=0">
        <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png?v=0">
        <link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png?v=0">
        <link rel="manifest" href="/site.webmanifest?v=1">
        <link rel="mask-icon" href="/safari-pinned-tab.svg?v=0" color="#e9658b">
        <link rel="shortcut icon" href="/favicon.ico?v=0">

        <meta name="apple-mobile-web-app-title" content="Flirtual">
        <meta name="application-name" content="Flirtual">
        <meta name="msapplication-TileColor" content="#e9658b">
        <meta name="theme-color" content="#e9658b">

        <meta charset="UTF-8">
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=1" />

        <link rel="stylesheet" href="/css/swiper.css?v=2">

        <style>
            @font-face {
                font-family: 'Nunito';
                font-style: normal;
                font-weight: 400;
                src: url('/font/nunito-v22-latin-regular.eot'); /* IE9 Compat Modes */
                src: local(''),
                     url('/font/nunito-v22-latin-regular.eot?#iefix') format('embedded-opentype'), /* IE6-IE8 */
                     url('/font/nunito-v22-latin-regular.woff2') format('woff2'), /* Super Modern Browsers */
                     url('/font/nunito-v22-latin-regular.woff') format('woff'), /* Modern Browsers */
                     url('/font/nunito-v22-latin-regular.ttf') format('truetype'), /* Safari, Android, iOS */
                     url('/font/nunito-v22-latin-regular.svg#Nunito') format('svg'); /* Legacy iOS */
                font-display: swap;
            }
            @font-face {
                font-family: 'Montserrat';
                font-style: normal;
                font-weight: 800;
                src: url('/font/montserrat-v23-latin-800.eot'); /* IE9 Compat Modes */
                src: local(''),
                     url('/font/montserrat-v23-latin-800.eot?#iefix') format('embedded-opentype'), /* IE6-IE8 */
                     url('/font/montserrat-v23-latin-800.woff2') format('woff2'), /* Super Modern Browsers */
                     url('/font/montserrat-v23-latin-800.woff') format('woff'), /* Modern Browsers */
                     url('/font/montserrat-v23-latin-800.ttf') format('truetype'), /* Safari, Android, iOS */
                     url('/font/montserrat-v23-latin-800.svg#Montserrat') format('svg'); /* Legacy iOS */
                font-display: swap;
            }

            :root {
                --gradient-l: #ff8975;
                --gradient-r: #e9658b;
                --gradient: linear-gradient(110deg, var(--gradient-l) 10%, var(--gradient-r) 90%);

                --accent: var(--gradient-r);
                --bg: #fffaf0;
                --black: #131516;
                --white: #fffafa;
                --grey: #e4e4e4;

                --shadow-1: 0 2px 2px 0 rgba(0,0,0,0.14),
                            0 3px 1px -2px rgba(0,0,0,0.12),
                            0 1px 5px 0 rgba(0,0,0,0.2);
                --shadow-2: 0 8px 17px 2px rgba(0,0,0,0.14),
                            0 3px 14px 2px rgba(0,0,0,0.12),
                            0 5px 5px -3px rgba(0,0,0,0.2);
                --shadow-3: 0 24px 38px 3px rgba(0,0,0,0.14),
                            0 9px 46px 8px rgba(0,0,0,0.12),
                            0 11px 15px -7px rgba(0,0,0,0.2);

                --swiper-theme-color: var(--white);
            }

            @media only screen and (max-width: 991px) {
                .desktop {
                    display: none;
                }
            }
            @media only screen and (min-width: 992px) {
                .mobile {
                    display: none;
                }

                .swiper-pagination {
                    transform: scale(2) !important;
                    right: 2vw !important;
                }
            }

            .right {
                float: right;
            }
            .center {
                text-align: center;
            }

            html,
            body {
                position: relative;
                height: 100%;
            }

            body {
                background: #eee;
                font-family: Nunito, sans-serif;
                font-size: 14px;
                color: var(--black);
                margin: 0;
                padding: 0;
            }

            h1, h2, h3, h4, h5, h6 {
                font-family: Montserrat, sans-serif;
            }

            .swiper {
                width: 100%;
                height: 100%;
            }

            .swiper-slide {
                text-align: center;
                font-size: 18px;
                background-color: var(--white);
            }

            .swiper-slide img {
                display: block;
                width: 100%;
                height: 100%;
                object-fit: cover;
            }

            #slide-1, #slide-3, #slide-5, #slide-6 {
                background: var(--gradient);
                color: var(--white);
            }

            #slide-1 div {
                position: absolute;
                top: 50%;
                width: 100%;
                margin: 0;
                text-align: center;
                transform: translateY(-50%);
            }
            #slide-1 img {
                margin: 0 0 0 50%;
                width: auto;
                height: 10vw;
                transform: translateX(-50%);
            }
            #slide-1 small {
                font-size: 1.5vw;
            }
            #slide-1 h2 {
                margin: 3vw 0 0 0;
                font-size: 5vw;
            }
            #slide-1 p {
                position: absolute;
                left: 50%;
                bottom: 0.75vh;
                font-size: 4vw;
                line-height: 0;
                transform: translateX(-50%);
                cursor: default;
            }
            #slide-1 a {
                position: absolute;
                right: 4vh;
                top: 4vh;
                padding: 1.4vh 2.5vh;
                color: var(--accent);
                background: var(--white);
                border: 6px solid transparent;
                border-radius: 2vh;
                font-family: Montserrat, sans-serif;
                text-decoration: none;
                font-size: 4vh;
                text-align: center;
                box-shadow: var(--shadow-2);
                transition: box-shadow 0.15s;
                cursor: pointer;
                user-select: none;
            }
            #slide-1 a:hover {
                background-color: var(--black);
                color: var(--white);
            }
            #slide-1 a:active {
                box-shadow: var(--shadow-1);
            }

            #slide-2 video {
                z-index: -1;
                position: absolute;
                left: 0;
                top: 0;
                width: 100%;
                height: 100%;
                object-fit: cover;
                filter: brightness(0.7);
            }
            #slide-2 div {
                position: absolute;
                top: 50%;
                width: 100%;
                margin: 0;
                text-align: center;
                color: var(--white);
                transform: translateY(-50%);
            }
            #slide-2 h2 {
                margin: 0 0 10vh 0;
                font-size: 5vw;
                text-shadow: 0 0 16px #000;
            }
            #slide-2 a {
                margin: 0;
                padding: 1.4vh 2.5vh;
                color: var(--white);
                background: linear-gradient(110deg, var(--gradient-l), var(--gradient-r)) padding-box, var(--gradient) border-box;
                border: 6px solid transparent;
                border-radius: 2vh;
                font-family: Montserrat, sans-serif;
                text-decoration: none;
                font-size: 4vh;
                text-align: center;
                box-shadow: var(--shadow-3);
                transition: box-shadow 0.15s;
                cursor: pointer;
                user-select: none;
            }
            #slide-2 a:hover {
                color: var(--accent);
                background: var(--white);
            }
            #slide-2 a:active {
                box-shadow: var(--shadow-1);
            }

            #slide-3 .cards {
                position: absolute;
                left: 5vw;
                top: 50%;
                width: 40vw;
                height: calc(40vw * 1.5);
                max-width: calc(80vh * 0.67);
                max-height: 80vh;
                transform: translateY(-50%);
            }
            #slide-3 .cards .swiper-slide {
                border: 1.25vh solid var(--white);
                border-radius: 5vh;
                box-shadow: var(--shadow-3);
            }
            #slide-3 .text {
                position: absolute;
                right: 5vw;
                top: 50%;
                width: 40vw;
                min-width: calc(90vw - 80vh * 0.67 - 50px);
                transform: translateY(-50%);
            }
            #slide-3 .text h2 {
                font-size: 4vw;
            }
            #slide-3 .text .swiper-slide {
                font-size: 3vw;
                background: none;
            }

            #slide-4 h2 {
                z-index: 2;
                position: absolute;
                left: 0;
                top: 4vw;
                width: 100%;
                margin: 0;
                text-align: center;
                font-size: 3vw;
                color: var(--white);
                text-shadow: 0 0 16px #000;
            }
            #slide-4 .dates img {
                position: absolute;
                left: 0;
                top: 0;
                width: 100%;
                height: 100%;
            }
            #slide-4 .dates h3 {
                position: absolute;
                left: 0;
                top: 55%;
                width: 100%;
                margin: 0;
                font-family: Nunito, sans-serif;
                text-align: center;
                font-size: 5vw;
                color: var(--white);
                text-shadow: 0 0 16px #000;
                transform: translateY(-50%);
            }

            #slide-5 h2 {
                position: absolute;
                top: 4vh;
                width: 100%;
                margin: 0;
                text-align: center;
                font-size: 3vw;
                line-height: 3vw;
            }
            #slide-5 .people {
                position: absolute;
                top: calc(8vh + 3vw);
                width: 100%;
                height: calc(76vh - 3vw);
                margin: 0;
                background-color: var(--black);
                box-shadow: var(--shadow-2);
                pointer-events: none;
            }
            #slide-5 .swiper-wrapper {
                -webkit-transition-timing-function: linear !important;
                transition-timing-function: linear !important;
            }
            #slide-5 .people .swiper-slide {
                width: auto;
            }
            #slide-5 .people img {
                display: block;
                width: auto;
                height: 100%;
                object-fit: cover;
            }
            #slide-5 .press {
                z-index: 1;
                position: absolute;
                left: 4vh;
                right: 4vh;
                bottom: 4vh;
                height: 8vh;
            }
            #slide-5 .press img {
                display: inline-block;
                width: calc((100vw - 52vh) / 5);
                height: 100%;
                max-height: 8vh;
                object-fit: contain;
                margin: 0 4vh;
            }

            #slide-6 > div {
                position: absolute;
                top: 40%;
                width: 100%;
                margin: 0;
                text-align: center;
                color: var(--white);
                transform: translateY(-50%);
            }
            #slide-6 > div > h2 {
                margin: 0 0 10vh 0;
                font-size: 5vw;
            }
            #slide-6 > div > a {
                margin: 0;
                padding: 1.4vh 2.5vh;
                color: var(--accent);
                background: var(--white);
                border: 6px solid transparent;
                border-radius: 2vh;
                font-family: Montserrat, sans-serif;
                text-decoration: none;
                font-size: 4vh;
                text-align: center;
                box-shadow: var(--shadow-2);
                transition: box-shadow 0.15s;
                cursor: pointer;
                user-select: none;
            }
            #slide-6 > div > a:hover {
                color: var(--white);
                background: var(--black);
            }
            #slide-6 > div > a:active {
                box-shadow: var(--shadow-1);
            }

            footer {
                position: absolute;
                left: 0;
                right: 0;
                bottom: 0;
                color: var(--white);
                font-size: 125%;
            }
            footer > div {
                padding:30px 15%;
            }
            footer > div:last-child {
                padding: 15px 15%;
                color: var(--white);
                background-color: rgba(0, 0, 0, .07);
                font-size: 80%;
                text-align: left;
            }
            footer a {
                margin: 0 10px;
                white-space: nowrap;
                color: var(--white);
                text-decoration: none;
                cursor: pointer;
            }
            footer a:hover {
                opacity: 0.8;
            }
            footer img {
                display: inline-block !important;
                width: auto !important;
                height: 1em !important;
                filter: invert(100%) brightness(0.94);
            }
        </style>
    </head>

    <body>
        <div class="swiper landing swiper-v">
            <div class="swiper-wrapper">
                <div class="swiper-slide" id="slide-1">
                    <div>
                        <img src="/img/logo.svg?v=4" alt="Flirtual" />
                        <small>(previously VRLFP)</small>
                        <h2>Go on dates...</h2>
                    </div>
                    <p>⮟</p>
                    <a href="/login">Login</a>
                </div>

                <div class="swiper-slide" id="slide-2">
                    <video poster="https://media.flirtu.al/6be390d0-4479-4a98-8c7a-10257ea5585a/-/format/auto/-/quality/smart/-/resize/1920x/" autoplay loop muted playsinline disablepictureinpicture disableremoteplayback x-webkit-airplay="deny">
                        <source src="https://media.flirtu.al/300c30ee-6b22-48a7-8d40-dc0deaf673ed/video.webm" type="video/webm; codecs=vp9">
                        <source src="https://media.flirtu.al/e67df8d2-295c-4bc0-9ebf-33f477267edd/video.mp4" type="video/mp4">
                        <img data-blink-uuid="6be390d0-4479-4a98-8c7a-10257ea5585a" />
                    </video>
                    <div>
                        <h2>...in Virtual Reality.</h2>
                        <a href="/register">Sign up</a>
                    </div>
                </div>

                <div class="swiper-slide" id="slide-3">
                    <div class="swiper cards">
                        <div class="swiper-wrapper">
                            <div class="swiper-slide">
                                <img data-blink-ops="quality: best"
                                     data-blink-uuid="c3dc9ffc-ec55-4452-8680-d71ab0b2ea5f" />
                            </div>
                            <div class="swiper-slide">
                                <img data-blink-uuid="52bd312c-bfed-4724-9241-971e4e6e9fd3" />
                            </div>
                            <div class="swiper-slide">
                                <img data-blink-uuid="e644c457-fe50-4429-9b94-f203e02d2368" />
                            </div>
                        </div>
                    </div>
                    <div class="text">
                        <h2>Avatar Profiles</h2>
                        <div class="swiper cards-text">
                            <div class="swiper-wrapper">
                                <div class="swiper-slide">VR lets you be more real.</div>
                                <div class="swiper-slide">When you can choose how you look, it's personality that makes the difference.</div>
                                <div class="swiper-slide">Vibe check in VR before sending IRL pics or video calling.</div>
                            </div>
                            <div class="swiper-pagination"></div>
                        </div>
                    </div>
                </div>

                <div class="swiper-slide" id="slide-4">
                    <h2>Safe, magical dates in any VR app.<br />Easily meet people all over the world!</h2>
                    <div class="swiper dates">
                        <div class="swiper-wrapper">
                            <div class="swiper-slide">
                                <img data-blink-uuid="b9326c15-c996-488f-8d68-d7ea4cb8649b" />
                                <h3>Feed some ducks</h3>
                            </div>
                            <div class="swiper-slide">
                                <img data-blink-uuid="738f3d22-6f38-4059-9dd3-7fdd672acccd" />
                                <h3>Swim with sharks</h3>
                            </div>
                            <div class="swiper-slide">
                                <img data-blink-uuid="be840a83-86f9-4ba2-87ae-3cd93f73f099" />
                                <h3>Chill in a cafe</h3>
                            </div>
                            <div class="swiper-slide">
                                <img data-blink-uuid="107737a5-d694-43db-a082-0d71bdfc4105" />
                                <h3>Observe a black hole</h3>
                            </div>
                            <div class="swiper-slide">
                                <img data-blink-uuid="30023b24-f08a-43d4-918a-aa8940cefb24" />
                                <h3>Touch grass</h3>
                            </div>
                            <div class="swiper-slide">
                                <img data-blink-uuid="09402677-a01e-4f6b-9171-f8c533ec774f" />
                                <h3>Paint together</h3>
                            </div>
                            <div class="swiper-slide">
                                <img data-blink-uuid="7e736467-63c4-4ff4-9989-54546b24cc6f" />
                                <h3>Play some pool</h3>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="swiper-slide" id="slide-5">
                    <h2>Thousands of matches (and memories) made.</h2>
                    <div class="swiper people">
                        <div class="swiper-wrapper">
                            <div class="swiper-slide">
                                <img src="https://media.flirtu.al/a68e9441-8430-4a33-a067-04313d4d260c/-/format/auto/-/quality/smart/-/resize/x661/" />
                            </div>
                            <div class="swiper-slide">
                                <img src="https://media.flirtu.al/5e0d4116-2e60-4ae9-b865-3ce7d17c68ec/-/format/auto/-/quality/smart/-/resize/x661/" />
                            </div>
                            <div class="swiper-slide">
                                <img src="https://media.flirtu.al/01db5707-2aac-45cd-a80c-223c6e1b93f2/-/format/auto/-/quality/smart/-/resize/x661/" />
                            </div>
                            <div class="swiper-slide">
                                <img src="https://media.flirtu.al/b8ea7c5b-5110-46b7-8635-38728e8a77aa/-/format/auto/-/quality/smart/-/resize/x661/" />
                            </div>
                            <div class="swiper-slide">
                                <img src="https://media.flirtu.al/eea60bde-de1a-4f43-9f02-a218fddf2a73/-/format/auto/-/quality/smart/-/resize/x661/" />
                            </div>
                            <div class="swiper-slide">
                                <img src="https://media.flirtu.al/ad5cba2d-03ff-43eb-9cf3-e6986bb0be54/-/format/auto/-/quality/smart/-/resize/x661/" />
                            </div>
                            <div class="swiper-slide">
                                <img src="https://media.flirtu.al/40122187-d831-4131-ab8e-ee0f5544ce73/-/format/auto/-/quality/smart/-/resize/x661/" />
                            </div>
                            <div class="swiper-slide">
                                <img src="https://media.flirtu.al/17b87f45-0ef8-4dfa-80c4-c23450f09b30/-/format/auto/-/quality/smart/-/resize/x661/" />
                            </div>
                            <div class="swiper-slide">
                                <img src="https://media.flirtu.al/28eaf327-e2bd-4fd2-a7f9-4dd6be153bfc/-/format/auto/-/quality/smart/-/resize/x661/" />
                            </div>
                            <div class="swiper-slide">
                                <img src="https://media.flirtu.al/5bbf00fc-2c97-49b2-9f16-9d3c1a180ae8/-/format/auto/-/quality/smart/-/resize/x661/" />
                            </div>
                            <div class="swiper-slide">
                                <img src="https://media.flirtu.al/f3b27da8-4f36-4c7f-bd65-094421d28f22/-/format/auto/-/quality/smart/-/resize/x661/" />
                            </div>
                            <div class="swiper-slide">
                                <img src="https://media.flirtu.al/c0d8ad7f-a6df-4de8-a429-a8fa729bf447/-/format/auto/-/quality/smart/-/resize/x661/" />
                            </div>
                            <div class="swiper-slide">
                                <img src="https://media.flirtu.al/9f2de017-6b5a-4ca9-b858-95057889fd64/-/format/auto/-/quality/smart/-/resize/x661/" />
                            </div>
                            <div class="swiper-slide">
                                <img src="https://media.flirtu.al/b8b087b9-3ab3-4a05-b01a-166b502789f5/-/format/auto/-/quality/smart/-/resize/x661/" />
                            </div>
                        </div>
                        <div class="swiper-pagination"></div>
                    </div>
                    <div class="press">
                        <img data-blink-uuid="18e4a7ad-625a-42f6-b581-d14386ced012" />
                        <img data-blink-uuid="db2eb424-e837-4d64-85e0-e49409ae33a6" />
                        <img data-blink-uuid="54ffe640-1c54-4d8f-a754-4c7b7ca82456" />
                        <img data-blink-uuid="b779aa38-8592-48cd-8f9b-88228c5abc21" />
                        <img data-blink-uuid="1a03f086-7a3a-41f6-a7cf-035a83c10fa4" />
                    </div>
                </div>

                <div class="swiper-slide" id="slide-6">
                    <div>
                        <h2>Get Flirtual</h2>
                        <a href="/register">Sign up</a>
                    </div>
                    <footer>
                        <div class="center">
                            <a href="https://rovr.atlassian.net/servicedesk/customer/portal/3" target="_blank">
                                <img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiA/Pjxzdmcgdmlld0JveD0iMCAwIDUxMiA1MTIiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PHBhdGggZD0iTTUwMi4zIDE5MC44YzMuOS0zLjEgOS43LS4yIDkuNyA0LjdWNDAwYzAgMjYuNS0yMS41IDQ4LTQ4IDQ4SDQ4Yy0yNi41IDAtNDgtMjEuNS00OC00OFYxOTUuNmMwLTUgNS43LTcuOCA5LjctNC43IDIyLjQgMTcuNCA1Mi4xIDM5LjUgMTU0LjEgMTEzLjYgMjEuMSAxNS40IDU2LjcgNDcuOCA5Mi4yIDQ3LjYgMzUuNy4zIDcyLTMyLjggOTIuMy00Ny42IDEwMi03NC4xIDEzMS42LTk2LjMgMTU0LTExMy43ek0yNTYgMzIwYzIzLjIuNCA1Ni42LTI5LjIgNzMuNC00MS40IDEzMi43LTk2LjMgMTQyLjgtMTA0LjcgMTczLjQtMTI4LjcgNS44LTQuNSA5LjItMTEuNSA5LjItMTguOXYtMTljMC0yNi41LTIxLjUtNDgtNDgtNDhINDhDMjEuNSA2NCAwIDg1LjUgMCAxMTJ2MTljMCA3LjQgMy40IDE0LjMgOS4yIDE4LjkgMzAuNiAyMy45IDQwLjcgMzIuNCAxNzMuNCAxMjguNyAxNi44IDEyLjIgNTAuMiA0MS44IDczLjQgNDEuNHoiLz48L3N2Zz4=" alt="Contact" />
                            </a>
                            <a href="/discord" target="_blank">
                                <img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiA/Pjxzdmcgdmlld0JveD0iMCAwIDY0MCA1MTIiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PHBhdGggZD0iTTUyNC41MzEsNjkuODM2YTEuNSwxLjUsMCwwLDAtLjc2NC0uN0E0ODUuMDY1LDQ4NS4wNjUsMCwwLDAsNDA0LjA4MSwzMi4wM2ExLjgxNiwxLjgxNiwwLDAsMC0xLjkyMy45MSwzMzcuNDYxLDMzNy40NjEsMCwwLDAtMTQuOSwzMC42LDQ0Ny44NDgsNDQ3Ljg0OCwwLDAsMC0xMzQuNDI2LDAsMzA5LjU0MSwzMDkuNTQxLDAsMCwwLTE1LjEzNS0zMC42LDEuODksMS44OSwwLDAsMC0xLjkyNC0uOTFBNDgzLjY4OSw0ODMuNjg5LDAsMCwwLDExNi4wODUsNjkuMTM3YTEuNzEyLDEuNzEyLDAsMCwwLS43ODguNjc2QzM5LjA2OCwxODMuNjUxLDE4LjE4NiwyOTQuNjksMjguNDMsNDA0LjM1NGEyLjAxNiwyLjAxNiwwLDAsMCwuNzY1LDEuMzc1QTQ4Ny42NjYsNDg3LjY2NiwwLDAsMCwxNzYuMDIsNDc5LjkxOGExLjksMS45LDAsMCwwLDIuMDYzLS42NzZBMzQ4LjIsMzQ4LjIsMCwwLDAsMjA4LjEyLDQzMC40YTEuODYsMS44NiwwLDAsMC0xLjAxOS0yLjU4OCwzMjEuMTczLDMyMS4xNzMsMCwwLDEtNDUuODY4LTIxLjg1MywxLjg4NSwxLjg4NSwwLDAsMS0uMTg1LTMuMTI2YzMuMDgyLTIuMzA5LDYuMTY2LTQuNzExLDkuMTA5LTcuMTM3YTEuODE5LDEuODE5LDAsMCwxLDEuOS0uMjU2Yzk2LjIyOSw0My45MTcsMjAwLjQxLDQzLjkxNywyOTUuNSwwYTEuODEyLDEuODEyLDAsMCwxLDEuOTI0LjIzM2MyLjk0NCwyLjQyNiw2LjAyNyw0Ljg1MSw5LjEzMiw3LjE2YTEuODg0LDEuODg0LDAsMCwxLS4xNjIsMy4xMjYsMzAxLjQwNywzMDEuNDA3LDAsMCwxLTQ1Ljg5LDIxLjgzLDEuODc1LDEuODc1LDAsMCwwLTEsMi42MTEsMzkxLjA1NSwzOTEuMDU1LDAsMCwwLDMwLjAxNCw0OC44MTUsMS44NjQsMS44NjQsMCwwLDAsMi4wNjMuN0E0ODYuMDQ4LDQ4Ni4wNDgsMCwwLDAsNjEwLjcsNDA1LjcyOWExLjg4MiwxLjg4MiwwLDAsMCwuNzY1LTEuMzUyQzYyMy43MjksMjc3LjU5NCw1OTAuOTMzLDE2Ny40NjUsNTI0LjUzMSw2OS44MzZaTTIyMi40OTEsMzM3LjU4Yy0yOC45NzIsMC01Mi44NDQtMjYuNTg3LTUyLjg0NC01OS4yMzlTMTkzLjA1NiwyMTkuMSwyMjIuNDkxLDIxOS4xYzI5LjY2NSwwLDUzLjMwNiwyNi44Miw1Mi44NDMsNTkuMjM5QzI3NS4zMzQsMzEwLjk5MywyNTEuOTI0LDMzNy41OCwyMjIuNDkxLDMzNy41OFptMTk1LjM4LDBjLTI4Ljk3MSwwLTUyLjg0My0yNi41ODctNTIuODQzLTU5LjIzOVMzODguNDM3LDIxOS4xLDQxNy44NzEsMjE5LjFjMjkuNjY3LDAsNTMuMzA3LDI2LjgyLDUyLjg0NCw1OS4yMzlDNDcwLjcxNSwzMTAuOTkzLDQ0Ny41MzgsMzM3LjU4LDQxNy44NzEsMzM3LjU4WiIvPjwvc3ZnPg==" alt="Discord" />
                            </a>
                            <a href="https://twitter.com/getflirtual" target="_blank">
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
                </div>
            </div>
            <div class="swiper-pagination"></div>
        </div>

        <script src="/js/swiper.js?v=2"></script>
        <script src="https://media.flirtu.al/libs/blinkloader/3.x/blinkloader.min.js"></script>

        <script>
            if ("serviceWorker" in navigator) {
                window.addEventListener("load", function() {
                    navigator.serviceWorker.register("/sw.js").then(function(registration) {
                        console.log("ServiceWorker registration successful with scope: ", registration.scope);
                    }, function(err) {
                        console.log("ServiceWorker registration failed: ", err);
                    });
                });
            }

            var swiper = new Swiper(".landing", {
                direction: "vertical",
                pagination: {
                    el: ".swiper-pagination",
                    clickable: true,
                },
                keyboard: true,
                mousewheel: true,
            });

            var swiper2 = new Swiper(".cards", {
                effect: "cards",
                grabCursor: true,
                autoplay: {
                    delay: 5000,
                    disableOnInteraction: true,
                },
                keyboard: true,
            });
            var swiper3 = new Swiper(".cards-text", {
                effect: "fade",
                fadeEffect: {
                    crossFade: true,
                },
            });
            swiper2.controller.control = swiper3;
            swiper3.controller.control = swiper2;

            var swiper4 = new Swiper(".dates", {
                speed: 600,
                loop: true,
                autoplay: {
                    delay: 3000,
                    disableOnInteraction: false,
                },
                keyboard: true,
            });

            var swiper5 = new Swiper(".people", {
                spaceBetween: 0,
                slidesPerView: "auto",
                centeredSlides: true,
                speed: 4000,
                loop: true,
                loopedSlides: 1,
                autoplay: {
                    delay: 1,
                    disableOnInteraction: false,
                },
                on: {
                    slideChange: function() {
                        let lastVisibleItem = this.realIndex + this.params.slidesPerView
                        let slidesLength = this.slides.length - 2
                        let lastVisibleIndex = this.realIndex + this.params.slidesPerView
                        if (lastVisibleItem > slidesLength) {
                           this.slideTo(1)
                        }
                        if (lastVisibleIndex >= this.slides.length) {
                           this.slideTo((slidesLength - this.params.slidesPerView) + 1)
                        }
                    }
                }
            });

            window.Blinkloader.optimize({
                "pubkey": "130267e8346d9a7e9bea",
                "cdnBase": "https://media.flirtu.al",
                lazyload: false,
                "smartCompression": true,
                "retina": true,
                "webp": true,
                "responsive": true,
                "fadeIn": true
            });
        </script>
    </body>
</html>
