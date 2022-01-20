% if {logged_in} {
      <div class="box">
          <h1>Your Guest List</h1>
          <p>Contains five (awesome) people who share common interests and traits with you. Refreshes each day.</p>
          <a href="/guestlist" class="btn btn-mango">Guest list</a>
      </div>

      <div class="box">
          <h1>Community Groups</h1>
          <p>A list of cool VR community groups and Discords to join.</p>
          <a href="/g/" class="btn btn-mango">Browse groups</a>
      </div>

      <span id="invite"></span>
      <div class="box">
          <h1>Invite a friend</h1>
          <table style="width: 100%">
              <tr>
                  <td style="width: 1px; white-space: nowrap"><label for="invitecode">Invite link:</label></td>
                  <td><input id="invitecode" type="text" readonly="" onclick="this.select(); document.execCommand('copy'); this.value = 'Copied!'; this.onclick = ''" style="width: 100%; color: #000" value="https://ROVRapp.com/?invite=%(`{redis_html `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})-[:REFERRAL]->(r:referral) RETURN r.id'}}%)"></td>
              </tr>
          </table>
      </div>
% } {
      <div id="s0">
          <img src="/img/logo.png" class="left" />
          <a href="/login" class="right">Login</a>
      </div>

      <div id="s1" class="section"><div class="row center">
          <h1>Meet new people</h1>
          <h2>using any VR app or headset</h2>

          <br />
%         if {~ $q_invite [A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9]} {
              <a href="/register?invite=%($q_invite%)" class="btn btn-mango" style="white-space: nowrap; transform: translateY(24px)">Sign me up</a>
%         } {
              <a href="/register" class="btn btn-mango" style="white-space: nowrap; transform: translateY(24px)">Sign me up</a>
%         }
      </div></div>

      <div id="s2" class="section"><div class="row grid">
          <div>
              <!--<ul class="slideshow">
                  <li><img src="/img/s2a.png" /></li>
                  <li><img src="/img/s2b.png" /></li>
                  <li><img src="/img/s2c.png" /></li>
              </ul>-->
              <img src="/img/s2.gif" />
              <p style="color: var(--blueraspberry); font-family: filicudi-solid, sans-serif; text-align: center;">+&nbsp;1000's of custom profile&nbsp;tags</p>
          </div>
          <div>
              <h2>Meet cool people</h2>
              <p>Each day, ROVR shows you five VR users who share common interests or traits with you.</p>
              <p>You can add each other as friends, then message and meet up in VR!</p>
          </div>
      </div></div>

      <div id="s3" class="section"><div class="row grid">
          <div>
              <h2>Explore VR communities and events</h2>
              <p>From nightclubs and yoga to D&D and improv workshops, VR has something for everyone. Find groups and events across VR apps like VRChat, Altspace, and more.</p>
          </div>
          <div>
              <img src="/img/s3.png" />
          </div>
      </div></div>

      <div id="s4" class="section"><div class="row grid">
          <div>
              <img src="/img/s4.jpg" />
              <p style="color: var(--mango); font-family: filicudi-solid, sans-serif; text-align: center">+&nbsp;1000's more games&nbsp;and&nbsp;worlds</p>
          </div>
          <div>
              <h2>Make friends in VR</h2>
              <p>Easily meet up in any social VR app or multiplayer game you own!</p>
              <p><a href="/discord" target="_blank">Join our Discord</a> for updates and weekly community events, or contribute to our code.</p>
          </div>
      </div></div>

      <div id="s5" class="section">
          <div class="row center">
              <h1>Ready to get social?</h1>

              <br />
%             if {~ $q_invite [A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9]} {
                  <a href="/register?invite=%($q_invite%)" class="btn btn-blueraspberry" style="white-space: nowrap; transform: translate(8px, 20px)">Sign me up</a>
%             } {
                  <a href="/register" class="btn btn-blueraspberry" style="white-space: nowrap; transform: translate(8px, 20px)">Sign me up</a>
%             }
          </div>
      </div>

      <style>
          .content {
              background-image: none;
              background-color: #fff;
          }
          .content_inner {
              display: block;
              padding: 0;
          }

          .section {
              position: relative;
              height: 100%;
              padding: 0 0 0 50%;
          }
          .section > .row {
              position: absolute;
              top: 50%;
              width: 80%;
              max-width: 1500px;
              padding: 100px 0;
              transform: translate(-50%, -50%);
          }
          @media only screen and (min-width: 992px) {
              .grid {
                  display: grid;
                  justify-content: center;
                  align-content: center;
                  align-items: center;
                  gap: 64px;
                  grid-auto-flow: column;
              }
          }

          .section img {
              max-width: 100%;
          }

          .slideshow {
              list-style: none;
              margin: 0 auto;
              padding: 0;
          }
          .slideshow li {
              position: absolute;
          }
          li:nth-child(3) {
              animation: xfade 12s 0s infinite;
          }
          li:nth-child(2) {
              animation: xfade 12s 4s infinite;
          }
          li:nth-child(1) {
              animation: xfade 12s 8s infinite;
          }

          @keyframes xfade{
              17% {
                  opacity:1;
              }
              25% {
                  opacity:0;
              }
              92% {
                  opacity:0;
              }
          }

          #s0 {
              background-color: var(--blueraspberry);
              padding: 2.5em;
          }
          #s0 a {
              padding: 0.2em 0.4em;
              border: 6px solid #fff;
              color: #fff;
              font-family: filicudi-solid, sans-serif;
              font-size: 150%;
              text-decoration: none;
              text-transform: uppercase;
          }
          #s0 a:hover {
              background-color: #fff;
              color: var(--blueraspberry);
          }

          #s1 {
              height: calc(100vh - 187px);
              padding: 0 10%;
          }
          #s1 > .row {
              max-width: none;
              transform: translate(0, calc(-50% - 45px));
          }
          #s1 h1 {
              font-size: 300%;
              margin-bottom: 0;
          }

          #s1, #s3 {
              background-color: var(--blueraspberry);
              color: #fff;
          }
          #s5 {
              background-color: var(--mango);
          }

          .haveinvite {
              font-size: 150%;
          }
      </style>
% }
