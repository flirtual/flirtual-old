require_login
if {! isempty $onboarding && !~ $onboarding 1} {
    post_redirect /
}

if {!~ $REQUEST_METHOD POST} { return 0 }

# Validate survey
for (q = p_`{seq 9}) {
    if {!~ $$q true && !~ $$q false} {
        throw error 'Please answer all of the questions'
    }
}

# Compute personality traits
openness = 0
conscientiousness = 0
agreeableness = 0

if {~ $p_1 true} {
    ++ openness
} {
    -- openness
}
if {~ $p_2 true} {
    ++ openness
} {
    -- openness
}
if {~ $p_3 false} {
    ++ openness
} {
    -- openness
}

if {~ $p_4 true} {
    ++ conscientiousness
} {
    -- conscientiousness
}
if {~ $p_5 true} {
    ++ conscientiousness
} {
    -- conscientiousness
}
if {~ $p_6 false} {
    ++ conscientiousness
} {
    -- conscientiousness
}

if {~ $p_7 true} {
    ++ agreeableness
} {
    -- agreeableness
}
if {~ $p_8 true} {
    ++ agreeableness
} {
    -- agreeableness
}
if {~ $p_9 false} {
    ++ agreeableness
} {
    -- agreeableness
}

# Write
redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                   SET u.survey_1 = '$p_1', u.survey_2 = '$p_2', u.survey_3 = '$p_3',
                       u.survey_4 = '$p_4', u.survey_5 = '$p_5', u.survey_6 = '$p_6',
                       u.survey_7 = '$p_7', u.survey_8 = '$p_8', u.survey_9 = '$p_9',
                       u.openness = '$openness',
                       u.conscientiousness = '$conscientiousness',
                       u.agreeableness = '$agreeableness

# Proceed
if {! isempty $onboarding} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       SET u.onboarding = 2'
    post_redirect /onboarding/2
} {
    post_redirect '/settings#edit'
}
