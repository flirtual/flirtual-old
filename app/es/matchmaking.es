fn compute_matches a b {
    if {!~ $b ()} {
        b = '{username: '''$b'''}'
    }

    redis graph write 'MATCH (a:user {username: '''$a'''})-[match:MATCH]-(b:user '$^b') DELETE match'

    redis graph write 'MATCH (a:user {username: '''$a'''}), (b:user '$^b')

                       WHERE (a) <> (b) AND
                             NOT (a)-[:MATCHED]-(b) AND
                             NOT exists(a.onboarding) AND
                             NOT exists(b.onboarding) AND
                             (a)-[:LF]->(:relationship)<-[:LF]-(b) AND
                             (a)-[:GENDER]->(:gender)<-[:LF]-(b) AND
                             (b)-[:GENDER]->(:gender)<-[:LF]-(a) AND
                             b.age >= a.agemin AND
                             b.age <= a.agemax AND
                             a.age >= b.agemin AND
                             a.age <= b.agemax

                       OPTIONAL MATCH (b)-[aliked:LIKED]->(a)
                       OPTIONAL MATCH (a)-[bliked:LIKED]->(b)
                       OPTIONAL MATCH (b)-[apassed:PASSED]->(a)
                       OPTIONAL MATCH (a)-[bpassed:PASSED]->(b)

                       OPTIONAL MATCH (a)-[:TAGGED]->
                                      (custom_interests:interest {type: ''custom''})
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

                       WITH a, b,
                            count(DISTINCT aliked) AS count_aliked,
                            count(DISTINCT bliked) AS count_bliked,
                            count(DISTINCT apassed) AS count_apassed,
                            count(DISTINCT bpassed) AS count_bpassed,
                            count(DISTINCT custom_interests) AS count_custom_interests,
                            count(DISTINCT default_interests) AS count_default_interests,
                            count(DISTINCT games) AS count_games,
                            count(DISTINCT country) AS count_country,
                            (18 - (abs(a.openness - b.openness) +
                                   abs(a.conscientiousness - b.conscientiousness) +
                                   abs(a.agreeableness - b.agreeableness))) AS personality,
                            a.weight_custom_interests AS a_weight_custom_interests,
                            a.weight_default_interests AS a_weight_default_interests,
                            a.weight_games AS a_weight_games,
                            a.weight_country AS a_weight_country,
                            a.weight_personality AS a_weight_personality,
                            b.weight_custom_interests AS b_weight_custom_interests,
                            b.weight_default_interests AS b_weight_default_interests,
                            b.weight_games AS b_weight_games,
                            b.weight_country AS b_weight_country,
                            b.weight_personality AS b_weight_personality

                       WITH a, b,
                            (count_aliked * 30 +
                             count_apassed * -30 +
                             count_custom_interests * a_weight_custom_interests +
                             count_default_interests * a_weight_default_interests +
                             count_games * a_weight_games +
                             count_country * a_weight_country +
                             personality * a_weight_personality) AS ascore,
                            (count_bliked * 30 +
                             count_bpassed * -30 +
                             count_custom_interests * b_weight_custom_interests +
                             count_default_interests * b_weight_default_interests +
                             count_games * b_weight_games +
                             count_country * b_weight_country +
                             personality * b_weight_personality) AS bscore

                       CREATE (a)-[:MATCH {score: ascore}]->(b)
                       CREATE (b)-[:MATCH {score: bscore}]->(a)'
}

fn daily_user_matches user {
    redis graph write 'MATCH (a:user {username: '''$user'''})-[m:MATCH]->(b:user)
                       WITH a, b ORDER BY m.score DESC LIMIT 100
                       WITH a, b ORDER BY rand() LIMIT 20
                       CREATE (a)-[:DAILYMATCH]->(b)'
}

fn daily_matches user {
    if {! isempty $user} {
        daily_user_matches $user
    } {
        redis graph write 'MATCH (a:user)-[m:DAILYMATCH]->(b:user)
                           WHERE count(b) < 5
                           DELETE m'

        for (user = `{redis graph read 'MATCH (a:user)
                                        OPTIONAL MATCH (a)-[:DAILYMATCH]->(b:user)
                                        WITH DISTINCT a, b
                                        WHERE NOT exists(b)
                                        RETURN a.username'}) {
            daily_user_matches $user
        }
    }
}
