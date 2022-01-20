if {!~ $^logged_user kyle && !~ $^logged_user anthony} {
    post_redirect /login
}
