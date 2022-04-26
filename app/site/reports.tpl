%   reports = `{redis graph read 'MATCH (a:user)-[r:REPORTED {reviewed: false}]->(b:user)
%                                 RETURN id(r)
%                                 ORDER BY r.date DESC'}
%   shadowbans = `{redis graph read 'MATCH (u:user {shadowbanned: true}) RETURN count(u)'}

%   if {! isempty $reports} {
        <div class="notice" style="margin-bottom: 1em">%($#reports%) reports, %($shadowbans%) shadowbans</div>
%       for (report = $reports) {
%           (username reporter reason details shadowbanned) = \
%               `` \n {redis graph read 'MATCH (a:user)
%                                              -[r:REPORTED]->
%                                              (b:user)
%                                        WHERE id(r) = '$report'
%                                        RETURN b.username, a.username, r.reason, r.details,
%                                               exists(b.shadowbanned)'}
%           details = `{echo $^details | escape_html}
            <div class="box report">
%               if {~ $shadowbanned true} {
                    <strong style="color: #f00">Shadowbanned</strong><br />
%               }
                <strong>User:</strong> <a href="/%($username%)">%($username%)</a><br />
                <strong>Reporter:</strong> %($reporter%)<br />
                <strong>Reason:</strong> %($^reason%)<br />
                <strong>Details:</strong> %(`{redis_html $^details | escape_html}%)
            </div>
%       }
%   }