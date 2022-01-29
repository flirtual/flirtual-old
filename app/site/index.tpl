% if {logged_in} {
%     template tpl/profile.tpl kyle
% } {
      <div id="s0">
          <img src="/img/logo.png" class="left" />
          <a href="/login" class="right">Login</a>
      </div>

      <div id="s1" class="section"><div class="row center">
          <h1>Meet new people</h1>
          <h2>using any VR app or headset</h2>

          <br />
          <form action="/register" method="POST">
              <table style="max-width: 800px; margin: 0 auto">
                  <tr>
                      <td style="width: 100%">
                          <input type="email" name="email" required placeholder="whomstever@example.com" value="%(`{echo $^p_email | escape_html}%)">
                      </td>
                      <td>
                          <button type="submit" name="from_landingpage" value="true" class="btn" style="white-space: nowrap; transform: translateY(24px)">Sign me up</button>
                      </td>
                  </tr>
              </table>
          </form>
      </div></div>

      <div id="s2" class="section"><div class="row grid">
          <div>
              <!--<ul class="slideshow">
                  <li><img src="/img/s2a.png" /></li>
                  <li><img src="/img/s2b.png" /></li>
                  <li><img src="/img/s2c.png" /></li>
              </ul>-->
              <img src="/img/s2.gif" />
              <p style="font-family: filicudi-solid, sans-serif; text-align: center;">+&nbsp;1000's of custom profile&nbsp;tags</p>
          </div>
          <div>
              <h2>Meet cool people</h2>
              <p>Each day, VRLFP shows you five VR users who share common interests or traits with you.</p>
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
              <p style="color: var(--pink); font-family: filicudi-solid, sans-serif; text-align: center">+&nbsp;1000's more games&nbsp;and&nbsp;worlds</p>
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
              <form action="/register" method="POST">
                  <table style="max-width: 800px; margin: 0 auto 15px auto">
                      <tr>
                          <td style="width: 100%">
                              <input type="email" name="email" required placeholder="whomstever@example.com" value="%(`{echo $^p_email | escape_html}%)">
                          </td>
                          <td>
                              <button type="submit" name="from_landingpage" value="true" class="btn" style="white-space: nowrap; transform: translate(8px, 20px)">Sign me up</button>
                          </td>
                      </tr>
                  </table>
              </form>
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
              color: #fff;
          }
          #s5 {
              background-color: var(--pink);
          }
      </style>
% }
