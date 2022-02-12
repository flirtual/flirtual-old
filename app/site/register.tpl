% if {!logged_in} {
      <div class="box">
          <h1>Register</h1>

          <form action="" method="POST" accept-charset="utf-8">
              <label for="username">Username</label>
              <input type="text" name="username" id="username" required autocomplete="username" value="%(`{echo $^p_username | escape_html}%)">

              <label for="email">Email</label>
              <input type="email" name="email" id="email" required autocomplete="email" value="%(`{echo $^p_email | escape_html}%)">

              <label for="password">Password</label>
              <input type="password" name="password" id="password" required minlength="8" autocomplete="new-password"><button id="password_toggle" type="button" onclick="togglePassword(document.querySelector('#password'))">👁</button>
              <script type="text/javascript">
                  function togglePassword(p) {
                      if (p.classList.contains('password_shown')) {
                          p.type = 'password';
                          p.classList.remove('password_shown');
                          document.querySelector('#password_toggle').style.color = '#000';
                      } else {
                          p.type = 'text';
                          p.classList.add('password_shown');
                          document.querySelector('#password_toggle').style.color = 'var(--pink)';
                      }
                  }
              </script>

              <table>
                  <tr>
                      <td><input type="checkbox" name="tos" id="tos" value="true" %(`{if {~ $p_tos true} { echo checked }}%)></td>
                      <td><label for="tos" style="display: inline-block; width: 100%; transform: translateY(4px)">I agree to the <a href="/terms" target="_blank">Terms of Service</a> &amp; <a href="/privacy" target="_blank">Privacy Policy</a> and I'm at least 18 years of age</label></td>
                  </tr>
                  <tr><td></td></tr>
                  <tr>
                      <td><input type="checkbox" name="newsletter" id="newsletter" value="true" %(`{if {~ $p_newsletter true} { echo checked }}%)></td>
                      <td><label for="newsletter" style="display: inline-block; width: 100%; transform: translateY(4px)">Bless my inbox with Flirtual updates (we won't spam you)</label></td>
                  </tr>
              </table>

              <br />
              <label for="captcha">Are you a robot?</label>
              <div id="captcha" class="h-captcha"></div>
              <script src="https://js.hcaptcha.com/1/api.js?onload=renderCaptcha&render=explicit" async defer></script>

              <button type="submit" class="btn btn-gradient">Sign up</button>
          </form>
      </div>

      <script type="text/javascript">
          function renderCaptcha() {
              hcaptcha.render("captcha", {
                  sitekey: '%($HCAPTCHA_SITEKEY%)'
              });
          }
      </script>
% } {
      <div class="box">
          <h1>Register</h1>
          <p>You're already logged in!</p>
          <a href="/logout" class="btn">Logout</a>
      </div>
% }
