% if {! isempty $p_group} {
      <a href="/g/%(`{redis graph read 'MATCH (g:group {invite: '''$p_group'''}) RETURN g.url'}%)" class="btn btn-blueraspberry">Back to group</a>
% }