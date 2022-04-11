%{
(customer email vrlfp premium supporter lifetime) = \
    `` \n {redis graph read 'MATCH (u:user {username: '''$logged_user'''})
                             RETURN u.customer, u.email, exists(u.vrlfp), exists(u.premium),
                                    exists(u.supporter), exists(u.lifetime_premium)'}

if {isempty $customer} {
    customer = `{stripe customers 'description='$logged_user \
                                  'email='$email | jq -r '.id'}

    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       SET u.customer = '''$customer''''
}

if {~ $lifetime true} {
    supporter_min_month = 4.99
    supporter_min_year = 49.99
} {
    supporter_min_month = 14.99
    supporter_min_year = 149.99
}
%}

<div class="notice">
    Account status:
%   if {~ $lifetime true} {
%       if {~ $supporter true} {
            Supporter, Lifetime Premium 🌟🌠
%       } {
            Lifetime Premium 🌠
%       }
%   } {~ $supporter true} {
        Supporter 🌟
%   } {~ $premium true} {
        Premium ⭐
%   } {
        Free user
%   }

%   if {~ $premium true} {
        <ul>
            <li><a href="/likes">See who likes you</a></li>
            <li><a href="/">Browse unlimited profiles</a></li>
%           if {~ $supporter true} {
                <li><a href="/onboarding/1">Customizable matchmaking preferences</a></li>
%           }
        </ul>
%   }
</div>

% if {~ $lifetime false} {
      <div class="box">
          <h1>Lifetime Premium</h1>
%         if {~ $vrlfp true} {
              <h2><del>$49.99</del> $24.99</h2>
              <p>-50% for VRLFP users. Thanks for your early support!</p>
%         } {
              <h2>$49.99</h2>
%         }
          <p><strong>Limited time only:</strong> Lifetime Premium subscriptions cannot be purchased after May 15.</p>
          <ul>
              <li>See who likes you</li>
              <li>Browse unlimited profiles</li>
%             if {~ $supporter true} {
                  <li>Upgrade to Supporter for $4.99/mo or $49.99/yr<span class="required" aria-label="You'll need to cancel your current Supporter subscription first and resubscribe at the discounted rate." role="tooltip" data-microtip-position="top">*</span></li>
%             } {
                  <li>Upgrade to Supporter for $4.99/mo or $49.99/yr<span class="required" aria-label="Come back to this page after checkout for your discounted Supporter offering!" role="tooltip" data-microtip-position="top">*</span></li>
%             }
          </ul>
%         if {~ $supporter true} {
              <p>Your Supporter subscription will be downgraded to Premium. You can then resubscribe at the discounted rate.</p>
%         } {~ $premium true} {
              <p>Your Premium subscription will be upgraded to Lifetime.</p>
%         }
          <form action="" method="POST" accept-charset="utf-8">
              <input type="hidden" name="action" value="lifetime">
              <button type="submit" class="btn btn-gradient" style="padding-right: 13px">Subscribe 🌠</button>
          </form>
      </div>
% }

<div class="box">
    <h1>Premium</h1>
    <h2>$9.99/mo <small>(or $99.99/yr)</small></h2>
    <ul>
        <li>See who likes you</li>
        <li>Browse unlimited profiles</li>
    </ul>
%   if {~ $premium true} {
%       if {~ $lifetime true} {
            <p>You have Lifetime Premium!</p>
%       } {
%           if {~ $supporter true} {
                <p>You have Supporter! To downgrade to Premium, cancel your subscription first.</p>
%           } {
                <p>You have Premium!</p>
%           }
            <form action="" method="POST" accept-charset="utf-8">
                <input type="hidden" name="action" value="manage">
                <button type="submit" class="btn btn-gradient">Manage</button>
            </form>
%       }
%   } {
        <form action="" method="POST" accept-charset="utf-8">
            <input type="hidden" name="action" value="premium">
            <button type="submit" class="btn btn-gradient" style="padding-right: 13px">Subscribe ⭐</button>
        </form>
%   }
</div>

<div class="box">
    <h1>Supporter</h1>
    <h2>Pay what you want</h2>
    <ul>
        <li>All Premium features</li>
        <li>Customizable matchmaking preferences</li>
        <li>Experimental features as they are developed</li>
    </ul>
%   if {~ $supporter true} {
        <p>You have Supporter!</p>
        <form action="" method="POST" accept-charset="utf-8">
            <input type="hidden" name="action" value="manage">
            <button type="submit" class="btn btn-gradient">Manage</button>
        </form>
%   } {
%       if {~ $lifetime true} {
            <p>You will keep your Lifetime Premium status if you cancel your Supporter subscription.</p>
%       } {~ $premium true} {
            <p>Supporter will replace your Premium subscription. Any unused time on your Premium subscription will be discounted from your second Supporter invoice.</p>
%       }
        <form action="" method="POST" accept-charset="utf-8">
            <input type="hidden" name="action" value="supporter">
            <div style="position: absolute; bottom: 1.6em">
                <label for="price" style="margin-right: 4px">$</label>
                <input type="number" min="%($supporter_min_month%)" max="999999.99" step="0.01" name="price" id="price" style="width: 7em" value="%($supporter_min_month%)">
                <select id="interval" name="interval" required style="width: auto">
                    <option value="month">/mo</option>
                    <option value="year">/yr</option>
                </select>
            </div>
%           if {~ $premium true} {
                <button type="submit" class="btn btn-gradient" style="padding-right: 13px">Upgrade 🌟</button>
%           } {
                <button type="submit" class="btn btn-gradient" style="padding-right: 13px">Subscribe 🌟</button>
%           }
        </form>
%   }
</div>

% if {~ $supporter true} {
      <div class="box">
          <h1>Badge</h1>
          <h2>Supporter profile badge 🌟</h2>
          <p>Display Supporter badge on your profile?</p>
          <form action="" method="POST" accept-charset="utf-8">
              <input type="hidden" name="action" value="badge">
              <button type="submit" class="btn btn-back" name="nobadge" value="true">Hide</button>
              <button type="submit" class="btn btn-gradient" name="badge" value="true">Show</button>
          </form>
      </div>
% }

<script>
    if ((window.matchMedia("(display-mode: standalone)").matches) ||
        (window.navigator.standalone) ||
        document.referrer.includes("android-app://")) {
        document.querySelectorAll(".box form button").forEach((button) => {
            button.style.background = "#aaa";
            button.onclick = function(event) {
                event.preventDefault();
                alert("Sorry, we cannot take payments on the mobile app.");
            };
        });
    }

    document.getElementById("interval").addEventListener("change", function() {
        var price = document.getElementById("price");
        if (this.value == "month") {
            price.setAttribute("min", %($supporter_min_month%));
            price.value = %($supporter_min_month%);
        } else {
            price.setAttribute("min", %($supporter_min_year%));
            if (price.value < %($supporter_min_year%)) {
                price.value = %($supporter_min_year%);
            }
        }
    });
</script>
