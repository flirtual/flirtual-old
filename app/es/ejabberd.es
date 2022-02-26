fn xmpp cmd args {
    curl --basic --user $XMPP_USER'@'$XMPP_HOST:$XMPP_PASSWORD \
         -d $args \
         -H 'Content-Type: application/json' \
         -X POST \
         'https://'$XMPP_HOST:$XMPP_PORT'/api/'$^cmd >/dev/null >[2=1]
}
