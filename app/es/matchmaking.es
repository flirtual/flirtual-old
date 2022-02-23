fn compute_matches a b {
    date = `{yyyymmdd `{date -u | sed 's/  / 0/'}}

    # If we're supplied two usernames, pass them along to Redis.
    # Otherwise, we're computing all of the matches for one user.
    if {!~ $b ()} {
        b = '{username: '''$b'''}'
    }

    redis graph write 'MATCH (a:user {username: '''$a'''})-[match:MATCH]-(b:user '$^b')
                       DELETE match'

    users = `{redis replica graph read 'MATCH (a:user {username: '''$a'''})
                                              -[:GENDER]->(:gender)<-[:LF]-
                                              (b:user '$^b'),
                                              (b)-[:GENDER]->(:gender)<-[:LF]-(a)

                                        WHERE (a) <> (b) AND
                                              NOT (a)-[:MATCHED]-(b) AND
                                              (NOT exists(a.onboarding) OR exists(a.vrlfp)) AND
                                              (NOT exists(b.onboarding) OR exists(b.vrlfp)) AND
                                              NOT exists(a.banned) AND NOT exists(b.banned) AND
                                              floor(('$date' - b.dob) / 10000) >= a.agemin AND
                                              floor(('$date' - b.dob) / 10000) <= a.agemax AND
                                              floor(('$date' - a.dob) / 10000) >= b.agemin AND
                                              floor(('$date' - a.dob) / 10000) <= b.agemax

                                        RETURN b.username'}

    if {isempty $users} { users = () }

    for (b = $users) {
        (count_aliked count_bliked count_apassed count_bpassed count_custom_interests \
         count_strong_interests count_default_interests count_games count_country count_monopoly \
         count_serious personality a_weight_custom_interests a_weight_default_interests \
         a_weight_games a_weight_country a_weight_monopoly a_weight_serious a_weight_personality \
         b_weight_custom_interests b_weight_default_interests b_weight_games b_weight_country \
         b_weight_monopoly b_weight_serious b_weight_personality) = \
            `` \n {redis replica graph read 'MATCH (a:user {username: '''$a'''}),
                                                   (b:user {username: '''$b'''})

                                             OPTIONAL MATCH (b)-[aliked:LIKED]->(a)
                                             OPTIONAL MATCH (a)-[bliked:LIKED]->(b)
                                             OPTIONAL MATCH (b)-[apassed:PASSED]->(a)
                                             OPTIONAL MATCH (a)-[bpassed:PASSED]->(b)

                                             OPTIONAL MATCH (a)-[:TAGGED]->
                                                            (custom_interests:interest {type: ''custom''})
                                                            <-[:TAGGED]-(b)

                                             OPTIONAL MATCH (a)-[:TAGGED]->
                                                            (strong_interests:interest {type: ''strong''})
                                                            <-[:TAGGED]-(b)

                                             OPTIONAL MATCH (a)-[:TAGGED]->
                                                            (default_interests:interest {type: ''default''})
                                                            <-[:TAGGED]-(b)

                                             OPTIONAL MATCH (a)-[:PLAYS]->
                                                            (games:game)
                                                            <-[:PLAYS]-(b)

                                             OPTIONAL MATCH (a)-[:COUNTRY]->
                                                            (country:country)
                                                            <-[:COUNTRY]-(b)

                                             RETURN count(DISTINCT aliked),
                                                    count(DISTINCT bliked),
                                                    count(DISTINCT apassed),
                                                    count(DISTINCT bpassed),
                                                    count(DISTINCT custom_interests),
                                                    count(DISTINCT strong_interests),
                                                    count(DISTINCT default_interests),
                                                    count(DISTINCT games),
                                                    count(DISTINCT country),
                                                    a.monopoly = b.monopoly,
                                                    (a.serious = true AND b.serious = true),

                                                    abs(sign(a.openness) * sign(b.openness) *
                                                        sign(a.conscientiousness) * sign(b.conscientiousness) *
                                                        sign(a.agreeableness) * sign(b.agreeableness)) *
                                                    (18 - (abs(a.openness - b.openness) +
                                                           abs(a.conscientiousness - b.conscientiousness) +
                                                           abs(a.agreeableness - b.agreeableness))),

                                                    a.weight_custom_interests, a.weight_default_interests,
                                                    a.weight_games, a.weight_country, a.weight_monopoly,
                                                    a.weight_serious, a.weight_personality,
                                                    b.weight_custom_interests,
                                                    b.weight_default_interests, b.weight_games,
                                                    b.weight_country, b.weight_monopoly,
                                                    b.weight_serious, b.weight_personality'}

        for (factor = count_custom_interests count_strong_interests count_default_interests \
                      count_games count_country count_monopoly count_serious personality) {
            if {isempty $$factor || ~ $$factor false} {
                $factor = 0
            } {~ $$factor true} {
                $factor = 1
            }
        }

        ascore = `{awk 'BEGIN { printf "%f", '$count_aliked' * 10 + \
                                             '$count_bpassed' * -30 + \
                                             '$count_custom_interests' * '$a_weight_custom_interests' + \
                                             '$count_strong_interests' * '$a_weight_default_interests' * 1.7 + \
                                             '$count_default_interests' * '$a_weight_default_interests' + \
                                             '$count_games' * '$a_weight_games' + \
                                             '$count_country' * '$a_weight_country' + \
                                             '$count_monopoly' * '$a_weight_monopoly' + \
                                             '$count_serious' * '$a_weight_serious' + \
                                             '$personality' * '$a_weight_personality' }' | sed 's/\.?0*$//'}

        bscore = `{awk 'BEGIN { printf "%f", '$count_bliked' * 10 + \
                                             '$count_apassed' * -30 + \
                                             '$count_custom_interests' * '$b_weight_custom_interests' + \
                                             '$count_strong_interests' * '$b_weight_default_interests' * 1.7 + \
                                             '$count_default_interests' * '$b_weight_default_interests' + \
                                             '$count_games' * '$b_weight_games' + \
                                             '$count_country' * '$b_weight_country' + \
                                             '$count_monopoly' * '$b_weight_monopoly' + \
                                             '$count_serious' * '$b_weight_serious' + \
                                             '$personality' * '$b_weight_personality' }' | sed 's/\.?0*$//'}

        redis graph write 'MATCH (a:user {username: '''$a'''}),
                                 (b:user {username: '''$b'''})
                           CREATE (a)-[:MATCH {score: '$ascore'}]->(b),
                                  (b)-[:MATCH {score: '$bscore'}]->(a)'
    }
}

fn daily_matches users {
    if {isempty $users} {
        # Every user that doesn't already have daily matches waiting for them
        redis graph write 'MATCH (a:user)-[m:DAILYMATCH]->(b:user)
                           WHERE count(b) < 5
                           DELETE m'

        users = `{redis graph read 'MATCH (a:user)
                                    OPTIONAL MATCH (a)-[:DAILYMATCH]->(b:user)
                                    WITH DISTINCT a, b
                                    WHERE NOT exists(b)
                                    RETURN a.username'}
    } {
        redis graph write 'MATCH (a:user {username: '''$users'''})-[m:DAILYMATCH]->(b:user)
                           DELETE m'
    }
    for (user = $users) {
        redis graph write 'MATCH (a:user {username: '''$user'''})-[m:MATCH]->(b:user)
                           WITH a, b ORDER BY m.score DESC, rand() LIMIT 100
                           WITH a, b ORDER BY rand() LIMIT 20
                           CREATE (a)-[:DAILYMATCH]->(b)'
    }
}
