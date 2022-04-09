<div class="box">
    <h1>Stats</h1>

%{
    redis graph read 'MATCH (u:user)
                      RETURN u.registered
                      ORDER BY u.registered' |
        awk '{print NR " " $s}' |
        gnuplot -p -e 'set term svg enhanced mouse;
                       set xlabel "Date";
                       set ylabel "# users";
                       set key off;
                       set autoscale fix;
                       set xdata time;
                       set timefmt ''%Y-%m-%d'';
                       plot "/dev/stdin" using 2:1 with lines'

    redis graph read 'MATCH (u:user)
                      RETURN u.registered
                      ORDER BY u.registered' |
        tail -n 1000 |
        awk '{print NR " " $s}' |
        gnuplot -p -e 'set term svg enhanced mouse;
                       set xlabel "Date";
                       set ylabel "# users";
                       set key off;
                       set autoscale fix;
                       set xdata time;
                       set timefmt ''%Y-%m-%d'';
                       plot "/dev/stdin" using 2:1 with lines'

    cat /var/log/flirtual/dau |
        gnuplot -p -e 'set term svg enhanced mouse;
                       set xlabel "Date";
                       set ylabel "DAU";
                       set key off;
                       set autoscale fix;
                       set xdata time;
                       set timefmt ''%Y-%m-%d'';
                       plot "/dev/stdin" using 1:2 with lines'

    cat /var/log/flirtual/wau |
        gnuplot -p -e 'set term svg enhanced mouse;
                       set xlabel "Date";
                       set ylabel "WAU";
                       set key off;
                       set autoscale fix;
                       set xdata time;
                       set timefmt ''%Y-%m-%d'';
                       plot "/dev/stdin" using 1:2 with lines'

    cat /var/log/flirtual/mau |
        gnuplot -p -e 'set term svg enhanced mouse;
                       set xlabel "Date";
                       set ylabel "MAU";
                       set key off;
                       set autoscale fix;
                       set xdata time;
                       set timefmt ''%Y-%m-%d'';
                       plot "/dev/stdin" using 1:2 with lines'

    cat /var/log/flirtual/yau |
        gnuplot -p -e 'set term svg enhanced mouse;
                       set xlabel "Date";
                       set ylabel "YAU";
                       set key off;
                       set autoscale fix;
                       set xdata time;
                       set timefmt ''%Y-%m-%d'';
                       plot "/dev/stdin" using 1:2 with lines'

    cat /var/log/flirtual/registrations |
        gnuplot -p -e 'set term svg enhanced mouse;
                       set xlabel "Date";
                       set ylabel "Registrations";
                       set key off;
                       set autoscale fix;
                       set xdata time;
                       set timefmt ''%Y-%m-%d'';
                       plot "/dev/stdin" using 1:2 with lines'

    users = `{redis graph read 'MATCH (u:user)
                                RETURN count(u)'}

    vrlfpusers = `{redis graph read 'MATCH (u:user)
                                     WHERE exists(u.vrlfp)
                                     RETURN count(u)'}

    vrlfponboarded = `{redis graph read 'MATCH (u:user)
                                         WHERE exists(u.vrlfp) AND
                                               NOT exists(u.onboarding)
                                         RETURN count(u)'}

    newusers = `{redis graph read 'MATCH (u:user)
                                   WHERE NOT exists(u.vrlfp)
                                   RETURN count(u)'}

    onboarded = `{redis graph read 'MATCH (u:user)
                                    WHERE NOT exists(u.vrlfp) AND
                                          NOT exists(u.onboarding)
                                    RETURN count(u)'}

    likes = `{redis graph read 'MATCH (a:user)-[l:LIKED]->(b:user)
                                WHERE l.type <> ''homie''
                                RETURN count(l)'}

    homies = `{redis graph read 'MATCH (a:user)-[l:LIKED {type: ''homie''}]->(b:user)
                                 RETURN count(l)'}

    passes = `{+ `{redis graph read 'MATCH (a:user)-[p:PASSED]->(b:user)
                                     RETURN count(p)'} 1039151}

    matches = `{redis graph read 'MATCH (a:user)-[m:MATCHED]->(b:user)
                                  RETURN count(m)'}
%}

    <p>%($users%) registered users</p>
    <p>%(`{x `{/ $vrlfponboarded $vrlfpusers} 100}%)% of VRLFP users onboarded</p>
    <p>%(`{x `{/ $onboarded $newusers} 100}%)% of new users onboarded</p>
    <p>%($likes%) likes</p>
    <p>%($homies%) homies</p>
    <p>%($passes%) passes</p>
    <p>%($matches%) matches</p>
    <hr />

    <h2>Query logins</h2>
    <h3>Examples</h3>
    <ul>
        <li>Day: <span style="font-family: monospace">l.date = '2021-01-01'</span></li>
        <li>Week: <span style="font-family: monospace">l.date = '2021-01-01' or l.date = '2021-01-02' or l.date = '2021-01-03' or l.date = '2021-01-04' or l.date = '2021-01-05' or l.date = '2021-01-06' or l.date = '2021-01-07'</span></li>
        <li>Month: <span style="font-family: monospace">l.date starts with '2021-01-'</span></li>
    </ul>
    <form method="POST" accept-charset="utf-8">
        <table>
            <tr>
                <td><input type="checkbox" name="distinct" id="distinct" value="true" checked>
                <label for="distinct" style="display: inline-block">Unique</label></td>
            </tr>
        </table>
        <input type="text" name="login_query" value="%($^p_login_query%)" style="width: calc(100% + 35px); font-family: monospace"><br /><br />
        <button type="submit" class="btn btn-normal">Run</button><br />
    </form>
    <p>
%       if {! isempty $p_login_query} {
%           if {~ $p_distinct true} {
%               redis graph read 'match (u:user)-[:LOGIN]->(l:login) where '$^p_login_query' with distinct u return count(u)'
%           } {
%               redis graph read 'match (u:user)-[:LOGIN]->(l:login) where '$^p_login_query' return count(u)'
%           }
%       }
    </p>
    <hr />

    <h2>Query registrations</h2>
    <h3>Examples</h3>
    <ul>
        <li>Day: <span style="font-family: monospace">u.registered = '2021-01-01'</span></li>
        <li>Week: <span style="font-family: monospace">u.registered = '2021-01-01' or u.registered = '2021-01-02' or u.registered = '2021-01-03' or u.registered = '2021-01-04' or u.registered = '2021-01-05' or u.registered = '2021-01-06' or u.registered = '2021-01-07'</span></li>
        <li>Month: <span style="font-family: monospace">u.registered starts with '2021-01-'</span></li>
    </ul>
    <form method="POST" accept-charset="utf-8">
        <input type="text" name="registration_query" value="%($^p_registration_query%)" style="width: calc(100% + 35px); font-family: monospace"><br /><br />
        <button type="submit" class="btn btn-normal">Run</button><br />
    </form>
    <p>
%       if {! isempty $p_registration_query} {
%           redis graph read 'match (u:user) where '$^p_registration_query' return count(u)'
%       }
    </p>
    <hr />
</div>

<style>
    .box > svg {
        width: 100%;
        height: auto;
    }
    #gnuplot_plot_1 > g:nth-child(2) > path:nth-child(1) {
        stroke: var(--accent);
    }
</style>
