title = 'Premium'

require_login

if {!~ $REQUEST_METHOD POST} { return 0 }

(customer vrlfp lifetime) = `` \n {redis graph read 'MATCH (u:user {username: '''$logged_user'''})
                                                     RETURN u.customer, exists(u.vrlfp),
                                                            exists(u.lifetime_premium)'}

if {~ $p_action manage} {
    link = `{stripe billing_portal/sessions 'customer='$customer | jq -r '.url'}
    post_redirect $link
} {~ $p_action premium} {
    session = `{stripe checkout/sessions 'success_url=https://flirtu.al/subscribed' \
                                         'cancel_url=https://flirtu.al/premium' \
                                         'mode=subscription' \
                                         'customer='$customer \
                                         'line_items[0][price]=price_1KZpvdH8fcK1g7d5e5qhwNlg' \
                                         'line_items[0][quantity]=1' \
                                         'allow_promotion_codes=true' \
                                         'automatic_tax[enabled]=true' \
                                         'customer_update[address]=auto' | jq -r '.url'}
    post_redirect $session
} {~ $p_action lifetime} {
    session = `{stripe checkout/sessions 'success_url=https://flirtu.al/subscribed' \
                                         'cancel_url=https://flirtu.al/premium' \
                                         'mode=payment' \
                                         'customer='$customer \
                                         'line_items[0][price]=price_1KasMaH8fcK1g7d5R3CFUnhv' \
                                         'line_items[0][quantity]=1' \
                                         `{if {~ $vrlfp true} { echo 'discounts[0][coupon]=vrlfp' }} \
                                         'automatic_tax[enabled]=true' \
                                         'customer_update[address]=auto' | jq -r '.url'}
    post_redirect $session
} {~ $p_action supporter} {
    if {!~ $p_interval month && !~ $p_interval year} {
        throw error 'Invalid payment interval'
    }

    lifetime = `{redis graph read 'MATCH (u:user {username: '''$logged_user'''})
                                   RETURN exists(u.lifetime_premium)'}

    if {~ $p_interval month} {
        if {~ $lifetime true} {
            min = 4.99
        } {
            min = 14.99
        }
    } {
        if {~ $lifetime true} {
            min = 49.99
        } {
            min = 149.99
        }
    }

    if {isempty $p_price ||
        ! echo $p_price | grep -s '^[0-9]*(\.[0-9]([0-9])?)?$' ||
        lt $p_price $min ||
        gt $p_price 999999.99} {
        throw error 'Invalid price'
    }

    price = `{stripe prices 'unit_amount='`{x $p_price 100} \
                            'currency=usd' \
                            'recurring[interval]='$p_interval \
                            'tax_behavior=exclusive' \
                            'product=prod_LGQim2AINber1U' | jq -r '.id'}

    session = `{stripe checkout/sessions 'success_url=https://flirtu.al/subscribed' \
                                         'cancel_url=https://flirtu.al/premium' \
                                         'mode=subscription' \
                                         'customer='$customer \
                                         'line_items[0][price]='$^price \
                                         'line_items[0][quantity]=1' \
                                         'allow_promotion_codes=true' \
                                         'automatic_tax[enabled]=true' \
                                         'customer_update[address]=auto' | jq -r '.url'}
    post_redirect $session
} {~ $p_action badge} {
    if {~ $p_badge true} {
        redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                           SET u.supporter_badge = true'
    } {
        redis graph write 'MATCH (u:user {username: '''$logged_user'''})
                           SET u.supporter_badge = NULL'
    }
    post_redirect /$logged_user
}
