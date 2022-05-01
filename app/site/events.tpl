<div class="eventnav">
    <a href="/">
        <img src="/img/logo.svg" />
        <span class="desktop">The VR Dating App</span>
    </a>
    <a href="/discord">
        <img src="/img/joindiscord.png" class="right" />
    </a>
</div>

<div class="events">
    <h1>Next event</h1>
    <div class="box">
        <div class="name">
            <h2>Pop Punk DJ Night</h2>
        </div>
        <p>Time to vibe! Join us for three DJ sets followed by two hours of open decks.</p>
        <table>
            <tr>
                <td><img src="/img/when.svg" class="icon" /></td>
                <td class="date"></td>
            </tr>
            <tr>
                <td><img src="/img/where.svg" class="icon" /></td>
                <td>The Flirtual Club in <a href="https://hello.vrchat.com/" target="_blank">VRChat</a><br />
                    (PCVR, Quest, and Desktop compatible)</td>
            </tr>
        </table>
        <a href="/invite" class="btn btn-gradient">
            <img src="/img/vrchat.svg" />
            Join
        </a>
    </div>

    <h1>Upcoming events</h1>
    <div class="box">
        <div class="name">
            <h2>Speed Matching</h2>
        </div>
        <p>Meet new dates and homies in 5-minute rounds. Each room has randomized prompts for easy conversation.</p>
        <table>
            <tr>
                <td><img src="/img/when.svg" class="icon" /></td>
                <td class="date"></td>
            </tr>
            <tr>
                <td><img src="/img/where.svg" class="icon" /></td>
                <td>The Flirtual Speed Matching World in <a href="https://hello.vrchat.com/" target="_blank">VRChat</a><br />
                    (PCVR, Quest, and Desktop compatible)</td>
            </tr>
        </table>
    </div>
    <div class="box">
        <div class="name">
            <h2>DJ Night</h2>
        </div>
        <p>Time to vibe! Join us for three DJ sets followed by two hours of open decks.</p>
        <table>
            <tr>
                <td><img src="/img/when.svg" class="icon" /></td>
                <td class="date"></td>
            </tr>
            <tr>
                <td><img src="/img/where.svg" class="icon" /></td>
                <td>The Flirtual Club in <a href="https://hello.vrchat.com/" target="_blank">VRChat</a><br />
                    (PCVR, Quest, and Desktop compatible)</td>
            </tr>
        </table>
    </div>
    <div class="box">
        <div class="name">
            <h2>Speed Matching</h2>
        </div>
        <p>Meet new dates and homies in 5-minute rounds. Each room has randomized prompts for easy conversation.</p>
        <table>
            <tr>
                <td><img src="/img/when.svg" class="icon" /></td>
                <td class="date"></td>
            </tr>
            <tr>
                <td><img src="/img/where.svg" class="icon" /></td>
                <td>The Flirtual Speed Matching World in <a href="https://hello.vrchat.com/" target="_blank">VRChat</a><br />
                    (PCVR, Quest, and Desktop compatible)</td>
            </tr>
        </table>
    </div>
    <div class="box">
        <div class="name">
            <h2>DJ Night</h2>
        </div>
        <p>Time to vibe! Join us for three DJ sets followed by two hours of open decks.</p>
        <table>
            <tr>
                <td><img src="/img/when.svg" class="icon" /></td>
                <td class="date"></td>
            </tr>
            <tr>
                <td><img src="/img/where.svg" class="icon" /></td>
                <td>The Flirtual Club in <a href="https://hello.vrchat.com/" target="_blank">VRChat</a><br />
                    (PCVR, Quest, and Desktop compatible)</td>
            </tr>
        </table>
    </div>
</div>

<img src="/img/posters/20220501.png" class="poster" />

<style>
    nav, footer {
        display: none;
    }

    .eventnav {
        z-index: 100;
        position: fixed;
        top: 0;
        right: 0;
        left: 0;
        height: 100px;
        background: var(--gradient);
        box-shadow: var(--shadow-2);
    }
    .eventnav a:first-child img {
        height: 70px;
        margin: 20px 40px 10px 15px;
    }
    .eventnav span {
        position: absolute;
        top: 33px;
        color: var(--white);
    }
    .eventnav a:last-child img {
        height: 60px;
        margin: 22px 20px 18px 20px;
    }

    @media only screen and (min-width: 992px) {
        .poster {
            position: fixed;
            top: 100px;
            left: 0;
            height: calc(100% - 100px);
            box-shadow: var(--shadow-1);
        }
    
        .events {
            position: fixed;
            top: 100px;
            right: 0;
            bottom: 0;
            left: calc((100vh - 100px) * (3 / 4));
            padding: 2em;
            overflow-y: auto;
        }
    }
    @media only screen and (max-width: 991px) {
        .poster {
            position: absolute;
            width: 100%;
            left: 0;
            margin-top: 1.5em;
        }

        .events > h1:first-child {
            margin-top: -1em;
        }
        main {
            margin-bottom: 0 !important;
        }
    }

    h1 {
        font-family: Montserrat, sans-serif;
    }

    .box {
        margin: 0 0 1.5em 0;
        padding-top: 4em;
        border-radius: 50px;
    }
    .box:last-child {
        margin-bottom: 0;
    }

    .btn {
        padding-left: 2.5em;
    }
    .btn img {
        position: absolute;
        display: inline-block;
        height: 1.8em;
        top: 50%;
        left: -0.1em;
        transform: translateY(-50%);
    }

    td {
        padding: 2px 4px;
        vertical-align: baseline;
        font-size: 125%;
    }

    .icon {
        height: 1em;
        transform: translate(-4px, 4px);
    }
</style>

<script>
    var dates = [
        new Date('2022/05/01 1:00:00 UTC'),
        new Date('2022/05/01 6:00:00 UTC'),
        new Date('2022/05/08 4:00:00 UTC'),
        new Date('2022/05/08 6:00:00 UTC'),
        new Date('2022/05/15 1:00:00 UTC'),
        new Date('2022/05/15 6:00:00 UTC'),
        new Date('2022/05/22 4:00:00 UTC'),
        new Date('2022/05/22 6:00:00 UTC'),
        new Date('2022/05/29 1:00:00 UTC'),
        new Date('2022/05/29 6:00:00 UTC')
    ];

    var i = 0;
    [...document.querySelectorAll(".date")].forEach(p => {
        p.innerHTML = dates[i].toLocaleString([], {month: "long"});
        p.innerHTML += " " + dates[i].getDate();
        p.innerHTML += ", " + dates[i].toLocaleTimeString([], {hour: "numeric", minute: "2-digit"});
        i++;
        p.innerHTML += " - " + dates[i].toLocaleTimeString([], {hour: "numeric", minute: "2-digit"});
        p.innerHTML += " " + dates[i].toLocaleDateString([], {day: "2-digit", timeZoneName: "short"}).substring(4);
        i++;
    });
</script>
