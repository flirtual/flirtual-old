% if {!logged_in} {
      <div class="box">
          <h1>Login</h1>
          <form action="" method="POST" accept-charset="utf-8">
              <label for="username">Username<small>(or email... you do you)</small></label>
              <input type="text" name="username" id="username" required autocomplete="username" placeholder="vrlfpfan42" value="%(`{echo $^p_username | escape_html}%)">

              <label for="password">Password</label>
              <input type="password" name="password" id="password" required autocomplete="current-password" placeholder="••••••••••••••••">

              <input type="checkbox" name="staylogged" id="staylogged" value="true" %(`{if {~ $p_staylogged true} { echo checked }}%)>
              <label for="staylogged">Stay logged in</label>

              <button type="submit" class="btn btn-mango">Login</button>
          </form>
      </div>

      <div>
          <div class="box-half">
              <p>Forgot your password?</p>
              <a href="/forgot" class="btn btn-blueraspberry">Rectify</a>
          </div>
          <div class="box-half">
              <p>Don't have an account yet?</p>
              <a href="/register" class="btn btn-blueraspberry">Sign up</a>
          </div>
      </div>
% } {
      <div class="box">
          <h1>Login</h1>
          <p>You're already logged in!</p>
          <a href="/logout" class="btn btn-mango">Logout</a>
      </div>
% }
