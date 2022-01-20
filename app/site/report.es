require_login

if {!~ $REQUEST_METHOD POST} { return 0 }

# Validate type
if {!~ $p_type user && !~ $p_type group} {
    throw error 'Something went wrong. Please try again'
}

# Validate ID
if {! echo $p_id | grep -s '^'$allowed_user_chars'+$'} {
    throw error 'Invalid user/group'
}

p_details = `{echo $p_details | tr $NEWLINE ' '}

sed 's/\$type/'$p_type'/; s/\$id/'$p_id'/; s/\$details/'$^p_details'/' < mail/report | email mod 'New report'
