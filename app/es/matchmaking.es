fn compute_match user guest {
    redis graph write 'MATCH (user:user {username: '''$user'''}),
                             (guest:user {username: '''$guest'''})

                       WHERE NOT (user)-[:MATCH]-(guest)

                       OPTIONAL MATCH (mutual_inviter:user)
                       WHERE (user)-[:INVITED_BY]->(mutual_inviter) AND
                             (guest)-[:INVITED_BY]->(mutual_inviter)

                       OPTIONAL MATCH (second_deg_inviter:user)
                       WHERE ((user)-[:INVITED_BY]->(second_deg_inviter) AND
                              (second_deg_inviter)-[:INVITED_BY]->(guest)) OR
                             ((guest)-[:INVITED_BY]->(second_deg_inviter) AND
                              (second_deg_inviter)-[:INVITED_BY]->(user))

                       OPTIONAL MATCH (custom_tags:tag {category: ''custom''})
                       WHERE (user)-[:INTERESTED_IN]->(custom_tags) AND
                             (guest)-[:INTERESTED_IN]->(custom_tags)

                       OPTIONAL MATCH (default_tags_1:tag)
                       WHERE default_tags_1.category <> ''custom'' AND
                             default_tags_1.weight = 1 AND
                             (user)-[:INTERESTED_IN]->(default_tags_1) AND
                             (guest)-[:INTERESTED_IN]->(default_tags_1)

                       OPTIONAL MATCH (default_tags_100:tag)
                       WHERE default_tags_100.category <> ''custom'' AND
                             default_tags_100.weight = 100 AND
                             (user)-[:INTERESTED_IN]->(default_tags_100) AND
                             (guest)-[:INTERESTED_IN]->(default_tags_100)

                       OPTIONAL MATCH (user)-[wave:WAVED]->(guest)

                       OPTIONAL MATCH (friends:user)
                       WHERE (user)-[:FRIENDS]-(friends) AND
                             (guest)-[:FRIENDS]-(friends)

                       OPTIONAL MATCH (groups:group)
                       WHERE (user)-[:MEMBER]->(groups) AND
                             (guest)-[:MEMBER]->(groups)

                       OPTIONAL MATCH (games:game)
                       WHERE (user)-[:PLAYS]->(games) AND
                             (guest)-[:PLAYS]->(games)

                       WITH DISTINCT user, guest,
                                     (count(DISTINCT mutual_inviter) * 10 +
                                      count(DISTINCT second_deg_inviter) * 5 +
                                      count(DISTINCT custom_tags) * 40 +
                                      count(DISTINCT default_tags_1) * 0.1 +
                                      count(DISTINCT default_tags_100) * 10 +
                                      count(DISTINCT wave) * 30 +
                                      count(DISTINCT friends) * 5 +
                                      count(DISTINCT groups) * 20 +
                                      count(DISTINCT games) * 15) AS score
                       WITH user, guest,
                            (score + (18 - (abs(user.openness - guest.openness) +
                                           abs(user.conscientiousness - guest.conscientiousness) +
                                           abs(user.agreeableness - guest.agreeableness))) * 2.5) AS score

                       CREATE (user)-[match:MATCH {score: score}]->(guest)'
}

fn compute_user_matches user {
    for (guest = `{redis graph read 'MATCH (u:user {username: '''$user'''}),
                                           (g:user)
                                     WHERE (u) <> (g) AND
                                           NOT (u)-[:MATCH]-(g) AND
                                           NOT (u)-[:FRIENDS]-(g) AND
                                           NOT (u)-[:WAVED]->(g) AND
                                           NOT (u)-[:PASSED]->(g) AND
                                           NOT (u)-[:SEEN]->(g) AND
                                           NOT exists(g.onboarding)
                                     RETURN g.username'}) {
        compute_match $user $guest
    }

    redis graph write 'MATCH (u:user {username: '''$user'''})-[g:GUEST]->(:user) DELETE g'
    redis graph write 'MATCH (u:user {username: '''$user'''})-[m:MATCH]-(g:user)
                       WHERE exists(m.score) AND
                             NOT (u)-[:FRIENDS]-(g) AND
                             NOT (u)-[:WAVED]->(g) AND
                             NOT (u)-[:PASSED]->(g)
                       WITH u, g
                       ORDER BY m.score DESC
                       LIMIT 5
                       CREATE (u)-[:GUEST]->(g)'
}


fn compute_all_matches {
    redis graph write 'MATCH (:user)-[m:MATCH]->(:user)
                       DELETE m'
    redis graph write 'MATCH (:user)-[s:SEEN]->(:user)
                       WHERE s.date < '`{- $dateun 2592000}^'
                       DELETE s'
    for (user = `{redis graph read 'MATCH (u:user)
                                    WHERE NOT exists(u.onboarding) AND
                                          u.lastlogin > '`{- $dateun 86400}^'
                                    RETURN u.username'}) {
        compute_user_matches $user
    }
}
