fn hcaptcha token {
    ! isempty $token &&
    curl -d 'response='$token'&secret='$HCAPTCHA_SECRET'&sitekey='$HCAPTCHA_SITEKEY \
         -X POST \
         'https://hcaptcha.com/siteverify' |
        grep -s '"success":true'
}
