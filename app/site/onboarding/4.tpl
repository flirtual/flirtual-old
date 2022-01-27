%{
avatar = `` \n {redis graph read 'MATCH (u:user {username: '''$logged_user'''})
                                  RETURN u.avatar'}

if {isempty $avatar} {
    avatar = defaults/01
}
%}

<div class="box">
    <h1>Choose your look</h1>

    <form action="" method="POST" accept-charset="utf-8" class="avatar_picker">
        <div class="tabs">
            <div onclick="select_tab(this, 'tab_defaults')" class="active">Standard</div><div onclick="select_tab(this, 'tab_hobbies')">Hobbies</div><div onclick="select_tab(this, 'tab_food')">Food</div><div onclick="select_tab(this, 'tab_stuff')">Stuff</div><div onclick="select_tab(this, 'tab_morestuff')">More Stuff</div>
        </div>

        <div id="tab_defaults" class="tab_content active">
            <div class="avatar_grid">
                <label for="defaults/01">
                    <input type="radio" id="defaults/01" name="avatar" value="defaults/01" %(`{if {~ $avatar defaults/01} { echo checked }}%)>
                    <img src="/img/avatars/120/defaults/01.png" />
                </label>
%               for (i = `{seq -w 02 15 | shuf}) {
                    <label for="defaults/%($i%)">
                        <input type="radio" id="defaults/%($i%)" name="avatar" value="defaults/%($i%)" %(`{if {~ $avatar defaults/$i} { echo checked }}%)>
                        <img src="/img/avatars/120/defaults/%($i%).png" />
                    </label>
%               }
            </div>
        </div>

        <div id="tab_hobbies" class="tab_content">
            <div class="avatar_grid">
%               for (i = `{seq -w 25 | shuf}) {
                    <label for="hobbies/%($i%)">
                        <input type="radio" id="hobbies/%($i%)" name="avatar" value="hobbies/%($i%)" %(`{if {~ $avatar hobbies/$i} { echo checked }}%)>
                        <img src="/img/avatars/120/hobbies/%($i%).png" />
                    </label>
%               }
            </div>
        </div>

        <div id="tab_food" class="tab_content">
            <div class="avatar_grid">
%               for (i = `{seq -w 25 | shuf}) {
                    <label for="food/%($i%)">
                        <input type="radio" id="food/%($i%)" name="avatar" value="food/%($i%)" %(`{if {~ $avatar food/$i} { echo checked }}%)>
                        <img src="/img/avatars/120/food/%($i%).png" />
                    </label>
%               }
            </div>
        </div>

        <div id="tab_stuff" class="tab_content">
            <div class="avatar_grid">
%               for (i = `{seq -w 25 | shuf}) {
                    <label for="stuff/%($i%)">
                        <input type="radio" id="stuff/%($i%)" name="avatar" value="stuff/%($i%)" %(`{if {~ $avatar stuff/$i} { echo checked }}%)>
                        <img src="/img/avatars/120/stuff/%($i%).png" />
                    </label>
%               }
            </div>
        </div>

        <div id="tab_morestuff" class="tab_content">
            <div class="avatar_grid">
%               for (i = `{seq -w 25 | shuf}) {
                    <label for="morestuff/%($i%)">
                        <input type="radio" id="morestuff/%($i%)" name="avatar" value="morestuff/%($i%)" %(`{if {~ $avatar morestuff/$i} { echo checked }}%)>
                        <img src="/img/avatars/120/morestuff/%($i%).png" />
                    </label>
%               }
            </div>
        </div>

        <p>Custom profile pics coming soon!</p>

%       if {! isempty $onboarding} {
            <button type="submit" class="btn btn-mango">Next page</button>
%       } {
            <button type="submit" class="btn btn-mango">Save</button>
%       }
    </form>
%   if {! isempty $onboarding} {
        <form id="form" action="" method="POST" accept-charset="utf-8">
            <button type="submit" name="back" value="true" class="btn btn-blueraspberry btn-back">Back</button>
        </form>
%   }
</div>
