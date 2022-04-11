%{
(profile serious monopoly displayname dob country country_id open conscientious agreeable \
 privacy_personality privacy_sexuality) = \
    `` \n {redis graph read 'MATCH (u:user)
                             WHERE u.id = '''$q_id'''
                             OPTIONAL MATCH (u)-[:COUNTRY]->(c:country)
                             RETURN u.username, u.serious, u.monopoly, u.displayname, u.dob, c.name,
                                    toLower(c.id), sign(u.openness), sign(u.conscientiousness),
                                    sign(u.agreeableness), u.privacy_personality,
                                    u.privacy_sexuality'}

avatar = `{redis graph read 'MATCH (u:user {username: '''$profile'''})-[:AVATAR]->(a:avatar)
                             RETURN a.url ORDER BY a.order LIMIT 1'}

# User-provided profile data needs formatting + sanitization
displayname = `{redis_html $displayname}

# Authenticate against privacy settings
fn isvisible field {
    ~ $(privacy_$field) everyone
}
%}

<style>
    nav, footer {
        display: none;
    }

    .box.profile {
        position: fixed;
        top: 0;
        left: 0;
        width: 1200px;
        height: 630px;
        border: none;
        border-radius: 0;
        box-shadow: none;
    }

    .pfp {
        position: absolute;
        left: 60px;
        top: 140px;
        width: 430px;
        height: 430px;
        background: linear-gradient(var(--white), var(--white)) padding-box,
                    var(--gradient) border-box;
        border: 12px solid transparent;
        border-radius: 45px;
        box-shadow: var(--shadow-2);
    }

    .name {
        border-radius: 0 0 45px;
        box-shadow: var(--shadow-2);
    }

    .logo {
        position: absolute;
        bottom: 10px;
        right: 16px;
        height: 48px;
    }

    .tags_container {
        position: absolute;
        top: 140px;
        right: 60px;
        bottom: 60px;
        left: 574px;
        overflow: hidden;
    }
    .tags {
        position: absolute;
        top: 50%;
        transform: translateY(-50%);
    }

    .tag {
        font-size: 24px;
        font-weight: bold;
    }

    .country {
        transform: translateY(7px);
    }
</style>

<div class="box profile">
    <img class="pfp" src="https://media.flirtu.al/%($avatar%)/-/scale_crop/406x406/center/" />

    <div class="name">
        <h2>%($displayname%)</h2>
    </div>

    <div class="tags_container"><div class="tags">
%{
        # Age
        age = `{int `{/ `{- `{yyyymmdd `{date -u | sed 's/  / 0/'}} `{echo $dob | sed 's/-//g'}} 10000}}
        if {le $age 125} {
            tags = ($tags $age)
        }

        # Gender
        genders = `` \n {redis graph read 'MATCH (u:user {username: '''$profile'''})-[:GENDER]->(g:gender)
                                          RETURN g.name
                                          ORDER BY g.order LIMIT 5' | sed 's/_/ /g'}
        if {! isempty $genders} {
            for (gender = $genders) {
                tags = ($tags $gender)
            }
        }

        # Location
        if {! isempty $country} {
            tags = ($tags '<span class="country_name" style="margin-right: 41px">'`^{echo $country | sed 's/_/ /g'}^'</span>
                           <span style="position: absolute; transform: translate(-31px, -3px)">
                               <img class="country" onerror="this.style.visibility='hidden'"
                                    src="/img/flags/'$country_id'.svg" width="33" height="25" />
                           </span>')
        }

        tag_count = 1
        for (i = $tags) {
            echo '<span class="tag common">'$i'</span>'
            ++ tag_count
        }

        # Open to serious dating
        if {~ $^serious true} {
            tags = ($tags 'Open to serious dating')
        }

        # Sexuality
        sexualities = `` \n {redis graph read 'MATCH (u:user {username: '''$profile'''})-[:SEXUALITY]->(s:sexuality)
                                               RETURN s.name
                                               ORDER BY s.order LIMIT 3' | sed 's/_/ /g'}
        if {isvisible sexuality && ! isempty $sexualities} {
            for (sexuality = $sexualities) {
                tags = ($tags $sexuality)
            }
        }

        # Personal tags
        interests = `{redis_html `{redis graph read 'MATCH (u:user {username: '''$profile'''})
                                                           -[:TAGGED]->(i:interest)
                                                     RETURN i.name ORDER BY i.name'}}
        if {! isempty $interests} {
            for (interest = $interests) {
                tags = ($tags `^{echo $interest | sed 's/_/ /g'})
            }
        }

        # Personality traits
        if {! {~ $open 0 && ~ $conscientious 0 && ~ $agreeable 0} && ! isempty $open} {
            if {~ $open 1} {
                tags = ($tags 'Open-minded')
            } {~ $open -1} {
                tags = ($tags 'Practical')
            }
            if {~ $conscientious 1} {
                tags = ($tags 'Reliable')
            } {~ $conscientious -1} {
                tags = ($tags 'Free-spirited')
            }
            if {~ $agreeable 1} {
                tags = ($tags 'Friendly')
            } {~ $agreeable -1} {
                tags = ($tags 'Straightforward')
            }
        }

        # Games
        games = `{redis_html `{redis graph read 'MATCH (u:user {username: '''$profile'''})
                                                       -[:PLAYS]->(g:game)
                                                 OPTIONAL MATCH (o:user)-[:PLAYS]->(g)
                                                 RETURN g.name ORDER BY count(o) DESC, g.name'}}
        if {! isempty $games} {
            for (game = $games) {
                tags = ($tags `^{echo $game | sed 's/_/ /g'})
            }
        }

        for (i = `{seq $tag_count 10}) {
            if {! isempty $tags($i)} {
                echo '<span class="tag">'$tags($i)'</span>'
            }
        }
%}
    </div></div>

    <img src="/img/logo_pink.svg" class="logo" />
</div>
