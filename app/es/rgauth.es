allowed_user_chars = '[a-zA-Z0-9_]'

fn login_user username password {
    if {logged_in} { return 0 }

    if {~ $req_path /login} {
        username = $p_username
        password = $p_password
    }

    if {! isempty $username && ! isempty $password} {
        # Initial login from /login form

        # Normalize case-insensitive username/email -> case-sensitive username
        username = `{echo $username | tr 'A-Z' 'a-z' | escape_redis}
        (username rpassword banned) = \
            `` \n {redis graph read 'MATCH (u:user)
                                     WHERE toLower(u.username) = '''$username''' OR
                                         toLower(u.email) = '''$username'''
                                     RETURN u.username, u.password, u.banned'}

        # Goodbye
        if {isempty $username ||
            ! kryptgo checkhash -b $rpassword -p $password} {
            dprint Failed login to $username from $HTTP_USER_AGENT on $REMOTE_ADDR
            throw error 'Wrong username/email or password'
        }
        if {~ $^banned true} {
            throw error 'Your account has been banned; please check your email for details'
        }

        # Generate new session ID
        sessionid = `{kryptgo genid}
        if {~ $sessionid -1} {
            dprint Session generation failed.
            throw error 'Something went wrong. Please try again later'
        }

        # We are logged in!
        logged_user = $username

        if {~ $p_staylogged true} {
            # Create session with inactive expiry in 30 days and absolute expiry in 365
            session_length = 2592000
            expiry = `{+ $dateun $session_length}
            expiryabs = `{+ $dateun 31536000}
        } {
            # Create session with inactive expiry in 30 mins and absolute expiry in 24 hours
            session_length = 1800
            expiry = `{+ $dateun $session_length}
            expiryabs = `{+ $dateun 86400}
        }
        onboarding = `{redis graph write 'MATCH (u:user {username: '''$username'''})
                                          CREATE (u)-[:SESSION]->(s:session {id: '''$sessionid''', length: '$session_length', expiry: '$expiry', expiryabs: '$expiryabs'}),
                                                 (u)-[:LOGIN]->(l:login {date: '''`{date -ui}^'''})
                                          SET u.lastlogin = '$dateun'
                                          RETURN u.onboarding'} # While we're in redis, get $onboarding so we know where to redirect

        dprint $logged_user logged in from $HTTP_USER_AGENT on $REMOTE_ADDR
    } {! isempty `{get_cookie id}} {
        # Existing login from session cookie

        sessionid = `{get_cookie id}

        # Check if ID is valid, session exists and is not expired
        if {! echo $sessionid | grep -s '^[a-zA-Z0-9_\-]+$' ||
            ~ `{redis graph read 'MATCH (s:session {id: '''$sessionid'''})
                                  RETURN exists(s) AND
                                         s.expiry >= '$dateun' AND
                                         s.expiryabs >= '$dateun} false} {
            user = `{redis graph read 'MATCH (u:user)-[:SESSION]->(s:session {id: '''$sessionid'''}) RETURN u.username'}
            xmpp kick_user '{"user": "'$user'", "host": "'$XMPP_HOST'"}'
            set_cookie id logout 'Thu, 01 Jan 1970 00:00:00 GMT'
            throw error 'Session expired. Please log in again'
        }

        # We are logged in! Update inactive expiry and get info we'll need later
        (logged_user session_length expiry expiryabs onboarding) = \
            `` \n {redis graph write 'MATCH (u:user)-[:SESSION]->(s:session {id: '''$sessionid'''})
                                      SET s.expiry = s.expiry + s.length,
                                          u.lastlogin = '$dateun'
                                      RETURN u.username, s.length, s.expiry, s.expiryabs, u.onboarding'}
    } {
        # The user has not requested to log in
        set_cookie id logout 'Thu, 01 Jan 1970 00:00:00 GMT'
        return 0
    }

    # "Stay logged in" unchecked -> delete cookie when the browser closes
    # Otherwise, set session cookie with expiration as min($expiry, $expiryabs)
    if {~ $session_length 1800} {
        set_cookie id $sessionid
    } {lt $expiry $expiryabs} {
        set_cookie id $sessionid `{cookiedate `{date -u $expiry}}
    } {
        set_cookie id $sessionid `{cookiedate `{date -u $expiryabs}}
    }

    # If the user hasn't finished setting up their profile, send them back to onboarding
    if {~ $req_path / && ! isempty $onboarding} {
        post_redirect /onboarding/$onboarding
    }

    # If this was an initial login from /login form, redirect...
    if {! isempty $username && ! isempty $password} {
        if {echo $q_redirect | grep -s '^[a-zA-Z0-9_/]+$' && !~ $q_redirect /logout} {
            # ...to the provided ?redirect=/path, if it's safe
            post_redirect $q_redirect
        } {
            # ...to the homepage
            post_redirect /
        }
    }
}

fn logout_user {
    # Delete all sessions, expire cookie, and redirect to /login
    user = `{redis graph read 'MATCH (u:user)-[:SESSION]->(s:session {id: '''`^{get_cookie id | sed 's/[^a-zA-Z0-9_\-]//g'}^'''}) RETURN u.username'}
    if {! isempty $user} {
        redis graph write 'MATCH (u:user {username: '''$user'''})-[:SESSION]->(s:session) DELETE s'
        xmpp kick_user '{"user": "'$user'", "host": "'$XMPP_HOST'"}'
        post_redirect /login
    }
}

fn logged_in { ! isempty $logged_user }
