fn stripe cmd args {
    curl -s -u $STRIPE_KEY: \
         `{for (arg = $args) { echo '-d '$arg }} \
         'https://api.stripe.com/v1/'$^cmd
}
