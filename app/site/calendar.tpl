<div class="box">
    <h1>Events</h1>
    <p>A calendar of weekly and one-time events happening in VRChat. Find cool things to do or add your own!</p>

    <div id="calendar"></div>

    <p><small>Thanks to VRChatevents.com, VRChat.com/events, various VR Discords, and our users for adding events to this calendar.</small></p>

    <a href="https://calendar.google.com/calendar/ical/c_ggidtr78rbela0btpp193quihc%40group.calendar.google.com/public/basic.ics" target="_blank" class="btn btn-blueraspberry btn-back">Add to your calendar</a>
    <a href="https://forms.gle/ZeFiZ1RP5g5HcALa6" target="_blank" class="btn btn-mango">Submit an event</a>
</div>

<script type="text/javascript" src="/js/jstz.js"></script>
<script>
    var timezone = jstz.determine();
    var prefix = '<iframe src="https://calendar.google.com/calendar/embed?height=600&wkst=1&bgcolor=%23ffffff&showTitle=0&showNav=1&showDate=1&showPrint=0&showTabs=1&showCalendars=0&mode=AGENDA&src=Y19nZ2lkdHI3OHJiZWxhMGJ0cHAxOTNxdWloY0Bncm91cC5jYWxlbmRhci5nb29nbGUuY29t&color=%23009688&ctz=';
    var suffix = '" style="border: 6px solid #000; padding: 20px; background-color: #fff" width="100%" height="600" frameborder="0" scrolling="no"></iframe>';
    var embed = prefix + timezone.name() + suffix;
    document.getElementById('calendar').innerHTML = embed;
</script>
