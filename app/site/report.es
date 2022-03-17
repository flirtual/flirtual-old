require_login

if {!~ $REQUEST_METHOD POST} { return 0 }

if {isempty $p_id} { return 0 }

# Validate ID
if {! echo $p_id | grep -s '^'$allowed_user_chars'+$'} {
    throw error 'Invalid user'
}

p_details = `{echo $p_details | tr $NEWLINE ' '}

sed 's/\$id/'$p_id'/; s/\$details/'$^p_details'/' < mail/report | email mod 'New report'
