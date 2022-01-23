fn email user subject {
    to = $user '<'`{redis graph read 'MATCH (u:user {username: '''$user'''}) RETURN u.email'}^'>'

    html = `{cat}
    plaintext = `{echo $html | sed 's/<a href="([^"]*)"[^>]*>[^<]*<\/a>/\1/g' |
                      html2text -style pretty | sed 's/$/\\n/'}

    link = `{echo $html | sed 's/.*href="([^"]*)".*/\1/'}
    if {!~ $link http*} {
        link = 'https://'$domain'/'
    } {~ $subject 'People want to meet you!'} {
        link = 'https://'$domain'/notifications'
    }

    sed 's/\\n /\n\n/g; s/\\n$//' << --EOF-- | /usr/sbin/sendmail -tif $mailfrom
From: $app <$mailfrom>
To: $to
Subject: [VRLFP] $subject
MIME-Version: 1.0
Content-Type: multipart/alternative; boundary="BOUNDARY"

--BOUNDARY
Content-Type: text/plain; charset=utf-8

$plaintext

Happy matching!

Twitter: https://twitter.com/vrlfp
Discord: https://$domain/discord
Unsubscribe: https://$domain/settings#notifications

© 2022 ROVR Labs
960 Western Rd. Unit 21 | London, ON | N6G 1G4 | Canada

--BOUNDARY
Content-Type: text/html; charset=utf-8

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" class=" js flexbox flexboxlegacy canvas canvastext webgl no-touch geolocation postmessage websqldatabase indexeddb hashchange history draganddrop websockets rgba hsla multiplebgs backgroundsize borderimage borderradius boxshadow textshadow opacity cssanimations csscolumns cssgradients cssreflections csstransforms csstransforms3d csstransitions fontface generatedcontent video audio localstorage sessionstorage webworkers no-applicationcache svg inlinesvg smil svgclippaths responsejs " style="" lang="en">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=" utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="robots" content="noindex, nofollow">
        <title>[VRLFP] $subject^</title>
        <style>
            .btn {
                color: #fff;
                padding: 0.65em 1.3em 0.5em 1.1em;
                transform: rotate(-5deg);
                display: inline-block;
                position: relative;
                margin: 1em 0.3em 0.3em 0;
                top: -0.8em;
                border: none;
                filter: drop-shadow(0.4em 0.5em #000);
                background-color: rgba(0,0,0,0);
                font-family: filicudi-solid, Verdana, Arial, sans-serif;
                text-decoration: none;
                text-align: center;
                cursor: pointer;
            }
            .btn::before {
                background-color: #25c9d0;
                -webkit-clip-path: polygon(0 0, 100% 0.3em, calc(100% - 0.9em) 100%, 0.5em 100%);
                clip-path: polygon(0 0, 100% 0.3em, calc(100% - 0.9em) 100%, 0.5em 100%);
                content: '';
                z-index: -1;
                position: absolute;
                top: 0;
                right: 0;
                bottom: 0;
                left: 0;
                font-weight: 500;
            }
        </style>
        <!--[if !mso]><!---->
        <style type="text/css">
            @font-face {
                font-family:"brandon-grotesque";
                src:url("https://use.typekit.net/af/d03e48/000000000000000077359df2/30/l?primer=7cdcb44be4a7db8877ffa5c0007b8dd865b3bbc383831fe2ea177f62257a9191&fvd=n5&v=3") format("woff2"),url("https://use.typekit.net/af/d03e48/000000000000000077359df2/30/d?primer=7cdcb44be4a7db8877ffa5c0007b8dd865b3bbc383831fe2ea177f62257a9191&fvd=n5&v=3") format("woff"),url("https://use.typekit.net/af/d03e48/000000000000000077359df2/30/a?primer=7cdcb44be4a7db8877ffa5c0007b8dd865b3bbc383831fe2ea177f62257a9191&fvd=n5&v=3") format("opentype");
                font-display:auto;font-style:normal;font-weight:500;
            }

            @font-face {
                font-family:"filicudi-solid";
                src:url("https://use.typekit.net/af/aff225/00000000000000007735ca36/30/l?primer=f592e0a4b9356877842506ce344308576437e4f677d7c9b78ca2162e6cad991a&fvd=n4&v=3") format("woff2"),url("https://use.typekit.net/af/aff225/00000000000000007735ca36/30/d?primer=f592e0a4b9356877842506ce344308576437e4f677d7c9b78ca2162e6cad991a&fvd=n4&v=3") format("woff"),url("https://use.typekit.net/af/aff225/00000000000000007735ca36/30/a?primer=f592e0a4b9356877842506ce344308576437e4f677d7c9b78ca2162e6cad991a&fvd=n4&v=3") format("opentype");
                font-display:auto;font-style:normal;font-weight:400;
            }
        </style>
        <!--<![endif]-->
        <!--[if mso]>
        <style type="text/css">
        body, table, td {font-family: brandon-grotesque, Roboto, Verdana, Arial, sans-serif; !important;}
        </style>
        <![endif]-->
    </head>
    <body style="margin: 0 !important;padding: 0 !important;-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;font-family: brandon-grotesque, Roboto, Verdana, Arial, sans-serif;height: 100% !important;width: 100% !important;-webkit-font-smoothing: antialiased !important;font-smoothing: antialiased !important;" class="ui-sortable">
    <table width="100%" height="100%" cellspacing="0" cellpadding="0" border="0" align="center" style="-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;border-collapse: collapse !important;">
        <tbody><tr>
            <td width="100%" valign="top" align="center" style="-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;">
                <center>
                    <table data-section-wrapper="1" width="100%" height="100%" cellspacing="0" cellpadding="0" border="0" style="-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;border-collapse: collapse !important;">
                        <tbody><tr data-section="1">
                            <td width="100%" valign="top" height="100%" align="center" style="-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;">
                                <!--[if (gte mso 9)|(IE)]>
                                <table align="center" border="0" cellspacing="0" cellpadding="0" width="660">
                                <tr>
                                <td align="center" valign="top" width="660">
                                <![endif]-->
                                <div data-slot-container="1" class="ui-sortable">
                                    <div data-slot="text"><table align="center" bgcolor="#00bf9a" border="0" cellpadding="0" cellspacing="0&quot;" style="max-width: 660px;-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;border-collapse: collapse !important;" width="100%"><tbody><tr><td align="center" bgcolor="#25c9d0" class="shrinker" height="124" style="background-repeat: no-repeat;background-size: 100%;background-color: #25c9d0;max-width: 660px;-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;" valign="top"><table align="center" border="0" cellpadding="0" cellspacing="0" class="shrinker" style="width: 100%;max-width: 550px;-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;border-collapse: collapse !important;" width="100%"><tbody><tr><td height="60" style="font-size: 60px;line-height: 60px;-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;">&nbsp;</td></tr><tr><td align="center" valign="top" style="-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;"><a href="https://$domain/" style="text-decoration: none;-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;" target="_blank">&nbsp;<img src="https://newsletter.vrlfp.net/media/images/VRLFP/logo.png" style="padding: 0px;border: medium none;width: 335px;height: 91.249px;line-height: 100%;outline: none;text-decoration: none;-ms-interpolation-mode: bicubic;" alt="VRLFP" class="fr-fil fr-dib" border="0" width="335" height="91.249">&nbsp;</a></td></tr><tr><td height="30" style="font-size: 30px;line-height: 30px;-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;">&nbsp;<br><br></td></tr></tbody></table></td></tr></tbody></table></div>
                                </div>
                            </td>
                        </tr>
                    </tbody></table>
                    <table data-section-wrapper="1" width="100%" height="100%" cellspacing="0" cellpadding="0" border="0" style="-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;border-collapse: collapse !important;">
                        <tbody><tr data-section="1">
                            <td width="100%" valign="top" height="100%" align="center" style="-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;">
                                <!--[if (gte mso 9)|(IE)]>
                                <table align="center" border="0" cellspacing="0" cellpadding="0" width="660">
                                <tr>
                                <td align="center" valign="top" width="660">
                                <![endif]-->
                                <table width="100%" cellspacing="0" cellpadding="0" border="0" align="center" style="-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;border-collapse: collapse !important;">
                                    <tbody><tr>
                                        <td style="font-family: brandon-grotesque, Roboto, Verdana, Arial, sans-serif;-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;" class="shrinker ui-sortable" data-slot-container="1" align="center">
                                            </td>
                                    </tr>
                                </tbody></table>
                                <!--[if (gte mso 9)|(IE)]>
                                </td>
                                </tr>
                                </table>
                                <![endif]-->
                            </td>
                        </tr>
                    </tbody></table>
                    <table data-section-wrapper="1" width="100%" height="100%" cellspacing="0" cellpadding="0" border="0" style="-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;border-collapse: collapse !important;">
                        <tbody><tr data-section="1">
                            <td width="100%" valign="top" height="100%" align="center" style="-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;">
                                <!--[if (gte mso 9)|(IE)]>
                                <table align="center" border="0" cellspacing="0" cellpadding="0" width="660">
                                <tr>
                                <td align="center" valign="top" width="660">
                                <![endif]-->
                                <table style="max-width: 660px;-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;border-collapse: collapse !important;" width="100%" cellspacing="0" cellpadding="0" border="0" bgcolor="#f0f0f0" align="center">
                                    <tbody><tr>
                                        <td style="font-family: brandon-grotesque, Roboto, Verdana, Arial, sans-serif;background: #f0f0f0;color: #212121;padding: 0 15px;-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;" class="shrinker ui-sortable" data-slot-container="1" align="center">
                                            <div data-slot="text"><table align="center" border="0" cellpadding="0" cellspacing="0" style="max-width: 550px;background: #ffffff;-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;border-collapse: collapse !important;" width="100%"><tbody><tr><td height="30" style="font-size: 30px;line-height: 30px;-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;">&nbsp;<br></td></tr><tr><td align="center" style="padding: 0 30px;text-align: left;-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;" valign="top">
<h1 style="font-family: filicudi-solid, Roboto, Verdana, Arial, sans-serif;">$subject^</h1>
$html
<p>Happy matching!</p>
</td></tr><tr><td style="font-size: 30px;line-height: 30px;-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;" height="30">&nbsp;<br></td></tr><tr><td style="padding: 0 30px;-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;" valign="top" align="center"><table style="max-width: 550px;background: #ffffff;-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;border-collapse: collapse !important;" width="100%" cellspacing="0" cellpadding="0" border="0" align="center"><tbody><tr><td style="font-size: 0px;line-height: 0px;border-bottom: 1px solid #e8e8e8;-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;" height="0">&nbsp;<br></td></tr></tbody></table>
</td></tr></tbody></table></div>
                                        </td>
                                    </tr>
                                </tbody></table>
                                <!--[if (gte mso 9)|(IE)]>
                                </td>
                                </tr>
                                </table>
                                <![endif]-->
                            </td>
                        </tr>
                    </tbody></table>
                    <table data-section-wrapper="1" width="100%" height="100%" cellspacing="0" cellpadding="0" border="0" style="-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;border-collapse: collapse !important;">
                        <tbody><tr data-section="1">
                            <td width="100%" valign="top" height="100%" align="center" style="-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;">
                                <!--[if (gte mso 9)|(IE)]>
                                <table align="center" border="0" cellspacing="0" cellpadding="0" width="660">
                                <tr>
                                <td align="center" valign="top" width="660">
                                <![endif]-->
                                <table style="max-width: 660px;-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;border-collapse: collapse !important;" width="100%" cellspacing="0" cellpadding="0" border="0" bgcolor="#f0f0f0" align="center">
                                    <tbody><tr>
                                        <td style="font-family: brandon-grotesque, Roboto, Verdana, Arial, sans-serif;background: #f0f0f0;color: #212121;padding: 0 15px;-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;" class="shrinker ui-sortable" data-slot-container="1" align="center">
                                        </td>
                                    </tr>
                                </tbody></table>
                                <!--[if (gte mso 9)|(IE)]>
                                </td>
                                </tr>
                                </table>
                                <![endif]-->
                            </td>
                        </tr>
                    </tbody></table>
                    <table data-section-wrapper="1" width="100%" height="100%" cellspacing="0" cellpadding="0" border="0" style="-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;border-collapse: collapse !important;">
                        <tbody><tr data-section="1">
                            <td width="100%" valign="top" height="100%" align="center" style="-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;">
                                <!--[if (gte mso 9)|(IE)]>
                                <table align="center" border="0" cellspacing="0" cellpadding="0" width="660">
                                <tr>
                                <td align="center" valign="top" width="660">
                                <![endif]-->
                                <table style="max-width: 660px;-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;border-collapse: collapse !important;" width="100%" cellspacing="0" cellpadding="0" border="0" bgcolor="#f0f0f0" align="center">
                                    <tbody><tr>
                                        <td style="font-family: brandon-grotesque, Roboto, Verdana, Arial, sans-serif;background: #f0f0f0;color: #212121;padding: 0 15px;-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;" class="shrinker ui-sortable" data-slot-container="1" align="center">
                                        </td>
                                    </tr>
                                </tbody></table>
                                <!--[if (gte mso 9)|(IE)]>
                                </td>
                                </tr>
                                </table>
                                <![endif]-->
                            </td>
                        </tr>
                    </tbody></table>
                    <table data-section-wrapper="1" width="100%" height="100%" cellspacing="0" cellpadding="0" border="0" style="-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;border-collapse: collapse !important;">
                        <tbody><tr data-section="1">
                            <td width="100%" valign="top" height="100%" align="center" style="-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;">
                                <!--[if (gte mso 9)|(IE)]>
                                <table align="center" border="0" cellspacing="0" cellpadding="0" width="660">
                                <tr>
                                <td align="center" valign="top" width="660">
                                <![endif]-->
                                <table style="max-width: 660px;-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;border-collapse: collapse !important;" width="100%" cellspacing="0" cellpadding="0" border="0" bgcolor="#f0f0f0" align="center">
                                    <tbody><tr>
                                        <td style="font-family: brandon-grotesque, Roboto, Verdana, Arial, sans-serif;background: #f0f0f0;color: #212121;padding: 0 15px;-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;" class="shrinker ui-sortable" data-slot-container="1" align="center">
                                        </td>
                                    </tr>
                                </tbody></table>
                                <!--[if (gte mso 9)|(IE)]>
                                </td>
                                </tr>
                                </table>
                                <![endif]-->
                            </td>
                        </tr>
                    </tbody></table>
                    <table data-section-wrapper="1" width="100%" height="100%" cellspacing="0" cellpadding="0" border="0" style="-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;border-collapse: collapse !important;">
                        <tbody><tr data-section="1">
                            <td width="100%" valign="top" height="100%" align="center" style="-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;">
                                <!--[if (gte mso 9)|(IE)]>
                                <table align="center" border="0" cellspacing="0" cellpadding="0" width="660">
                                <tr>
                                <td align="center" valign="top" width="660">
                                <![endif]-->
                                <table style="max-width: 660px;-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;border-collapse: collapse !important;" width="100%" cellspacing="0" cellpadding="0" border="0" bgcolor="#f0f0f0" align="center">
                                    <tbody><tr>
                                        <td style="font-family: brandon-grotesque, Roboto, Verdana, Arial, sans-serif;color: #212121;text-transform: uppercase;-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;" data-slot-container="1" class="ui-sortable" align="center">
                                            <div data-slot="text"><p style="font-family: brandon-grotesque, Roboto, Verdana, Arial, sans-serif; font-size:12px; line-height:18px; color:#212121; text-transform: uppercase; padding:0; margin:0;"><span style="font-size:9px;">If the link above doesn't work, try copying this URL into your browser: <a href="$link^" style="text-transform: none">$link^</a></span></p></div>
                                        </td>
                                    </tr>
                                </tbody></table>
                                <!--[if (gte mso 9)|(IE)]>
                                </td>
                                </tr>
                                </table>
                                <![endif]-->
                            </td>
                        </tr>
                    </tbody></table>
                    <table data-section-wrapper="1" width="100%" height="100%" cellspacing="0" cellpadding="0" border="0" style="-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;border-collapse: collapse !important;">
                        <tbody><tr data-section="1">
                            <td width="100%" valign="top" height="100%" align="center" style="-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;">
                                <!--[if (gte mso 9)|(IE)]>
                                <table align="center" border="0" cellspacing="0" cellpadding="0" width="660">
                                <tr>
                                <td align="center" valign="top" width="660">
                                <![endif]-->
                                <table style="max-width: 660px;-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;border-collapse: collapse !important;" width="100%" cellspacing="0" cellpadding="0" border="0" bgcolor="#f0f0f0" align="center">
                                    <tbody><tr>
                                        <td style="font-size: 15px;line-height: 15px;-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;" height="15">&nbsp;</td>
                                    </tr>
                                    <tr>
                                        <td style="font-family: brandon-grotesque, Roboto, Verdana, Arial, sans-serif;color: #212121;text-transform: uppercase;-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;" data-slot-container="1" class="ui-sortable" align="center">
                                            <div data-slot="text"><a href="https://twitter.com/vrlfp" rel="noopener noreferrer" style="font-family: brandon-grotesque, Roboto, Verdana, Arial, sans-serif;font-size: 10px;line-height: 20px;color: #212121;text-transform: uppercase;text-decoration: underline;-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;" target="_blank">Twitter</a>
<span style="font-family:arial, sans-serif; font-size:10px; line-height:20px; color:#dddddd;">&nbsp;|&nbsp;</span>
<a href="https://$domain/discord" rel="noopener noreferrer" style="font-family: brandon-grotesque, Roboto, Verdana, Arial, sans-serif;font-size: 10px;line-height: 20px;color: #212121;text-transform: uppercase;text-decoration: underline;-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;" target="_blank">Discord</a>
<span style="font-family:arial, sans-serif; font-size:10px; line-height:20px; color:#dddddd;">&nbsp;|&nbsp;</span>
<a href="https://$domain/settings#notifications" style="font-family: brandon-grotesque, Roboto, Verdana, Arial, sans-serif;font-size: 10px;line-height: 20px;color: #212121;text-transform: uppercase;text-decoration: underline;-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;" target="_blank">Unsubscribe</a></div>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="font-size: 15px;line-height: 15px;-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;" height="15">&nbsp;</td>
                                    </tr>
                                </tbody></table>
                                <!--[if (gte mso 9)|(IE)]>
                                </td>
                                </tr>
                                </table>
                                <![endif]-->
                            </td>
                        </tr>
                    </tbody></table>
                    <table data-section-wrapper="1" width="100%" height="100%" cellspacing="0" cellpadding="0" border="0" style="-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;border-collapse: collapse !important;">
                        <tbody><tr data-section="1">
                            <td width="100%" valign="top" height="100%" align="center" style="-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;">
                                <!--[if (gte mso 9)|(IE)]>
                                <table align="center" border="0" cellspacing="0" cellpadding="0" width="660">
                                <tr>
                                <td align="center" valign="top" width="660">
                                <![endif]-->
                                <table style="max-width: 660px;-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;border-collapse: collapse !important;" width="100%" cellspacing="0" cellpadding="0" border="0" bgcolor="#f0f0f0" align="center">
                                    <tbody><tr>
                                        <td style="font-family: brandon-grotesque, Roboto, Verdana, Arial, sans-serif;color: #212121;text-transform: uppercase;-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;" data-slot-container="1" class="ui-sortable" align="center">
                                            <div data-slot="text"><p style="font-family: brandon-grotesque, Roboto, Verdana, Arial, sans-serif; font-size:12px; line-height:18px; color:#212121; text-transform: uppercase; padding:0; margin:0;"><span style="font-size:9px;">© 2022 ROVR Labs</span><br><span style="font-size:9px;">960 Western Rd. Unit 21 | London, ON | N6G 1G4 | Canada</span></p></div>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="font-size: 20px;line-height: 20px;-webkit-text-size-adjust: 100%;-ms-text-size-adjust: 100%;mso-table-lspace: 0pt;mso-table-rspace: 0pt;" height="20">&nbsp;</td>
                                    </tr>
                                </tbody></table>
                                <!--[if (gte mso 9)|(IE)]>
                                </td>
                                </tr>
                                </table>
                                <![endif]-->
                            </td>
                        </tr>
                    </tbody></table>
                    <!--[if (gte mso 9)|(IE)]>
                    </td>
                    </tr>
                    </table>
                    <![endif]-->
                </center>
            </td>
        </tr>
    </tbody></table>
    <div style="display:none; white-space:nowrap; font:15px courier; line-height:0;">
    </div>
</body></html>
--BOUNDARY--
--EOF--
}
