require_login
if {! isempty $onboarding && !~ $onboarding 4} {
    post_redirect /
}

if {!~ $REQUEST_METHOD POST} { return 0 }

# Back button -> return to previous onboarding page
if {~ $p_back true} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''}) SET u.onboarding = 3'
    post_redirect /onboarding/3
}

# Validate privacy setting
if {!~ $p_privacy everyone && !~ $p_privacy matches && !~ $p_privacy me} {
    throw error 'Invalid privacy setting'
}

# Compute personality traits
openness = 0
conscientiousness = 0
agreeableness = 0

if {~ $p_1 true} {
    ++ openness
} {~ $p_1 false} {
    -- openness
} {
    p_1 = skipped
}
if {~ $p_2 true} {
    ++ openness
} {~ $p_2 false} {
    -- openness
} {
    p_2 = skipped
}
if {~ $p_3 false} {
    ++ openness
} {~ $p_3 true} {
    -- openness
} {
    p_3 = skipped
}

if {~ $p_4 true} {
    ++ conscientiousness
} {~ $p_4 false} {
    -- conscientiousness
} {
    p_4 = skipped
}
if {~ $p_5 true} {
    ++ conscientiousness
} {~ $p_5 false} {
    -- conscientiousness
} {
    p_5 = skipped
}
if {~ $p_6 false} {
    ++ conscientiousness
} {~ $p_6 true} {
    -- conscientiousness
} {
    p_6 = skipped
}

if {~ $p_7 true} {
    ++ agreeableness
} {~ $p_7 false} {
    -- agreeableness
} {
    p_7 = skipped
}
if {~ $p_8 true} {
    ++ agreeableness
} {~ $p_8 false} {
    -- agreeableness
} {
    p_8 = skipped
}
if {~ $p_9 false} {
    ++ agreeableness
} {~ $p_9 true} {
    -- agreeableness
} {
    p_9 = skipped
}

# Write
redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                   SET u.survey_1 = '$p_1', u.survey_2 = '$p_2', u.survey_3 = '$p_3',
                       u.survey_4 = '$p_4', u.survey_5 = '$p_5', u.survey_6 = '$p_6',
                       u.survey_7 = '$p_7', u.survey_8 = '$p_8', u.survey_9 = '$p_9',
                       u.openness = '$openness',
                       u.conscientiousness = '$conscientiousness',
                       u.agreeableness = '$agreeableness',
                       u.privacy_personality = '''$p_privacy''''

# Proceed
if {! isempty $onboarding} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       SET u.onboarding = 5'
    post_redirect /onboarding/5
} {
    redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                       SET u.recompute_matches = true'
    post_redirect '/settings#edit'
}
