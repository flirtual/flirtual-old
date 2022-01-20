<div class="box">
    <h1>Add/update game</h1>
    <form method="POST" accept-charset="utf-8">
        <label for="name">Name <small>Single-quotes (') are illegal. Underscores display as spaces.</small></label>
        <input type="text" name="name" value="%($^p_name%)">

        <label for="type">Type</label>
        <select name="type">
            <option value="game">Game</option>
            <option value="app">App</option>
            <option value="metaverse">Metaverse (with worlds)</option>
        </select>

        <label>Platform(s)</label>
        <div class="tags">
            <input id="quest" type="checkbox" name="Oculus_Quest" value="true" %($Oculus_Quest%)>
            <label for="quest">Oculus Quest</label>
            <input id="link" type="checkbox" name="Oculus_Link" value="true" %($Oculus_Link%)>
            <label for="link">Oculus Quest with Link</label>
            <input id="rift" type="checkbox" name="Oculus_Rift" value="true" %($Oculus_Rift%)>
            <label for="rift">Oculus Rift (S)</label>
            <input id="steamvr" type="checkbox" name="SteamVR" value="true" %($SteamVR%)>
            <label for="steamvr">SteamVR (Index, Vive, Pimax, etc.)</label>
            <input id="wmr" type="checkbox" name="Windows_Mixed_Reality" value="true" %($Windows_Mixed_Reality%)>
            <label for="wmr">Windows Mixed Reality (Reverb, Odyssey, etc.)</label>
            <input id="psvr" type="checkbox" name="PlayStation_VR" value="true" %($PlayStation_VR%)>
            <label for="psvr">PlayStation VR</label>
            <input id="desktop" type="checkbox" name="Desktop" value="true" %($Desktop%)>
            <label for="desktop">Desktop</label>
        </div>

        <label>Interest(s)</label>
        <div class="tags">
            <input id="bookworm" type="checkbox" name="Bookworm" value="yes" %($Bookworm%)>
            <label for="bookworm">Bookworm</label>
            <input id="fitness" type="checkbox" name="Fitness" value="yes" %($Fitness%)>
            <label for="fitness">Fitness</label>
            <input id="furry" type="checkbox" name="Furry" value="yes" %($Furry%)>
            <label for="furry">Furry</label>
            <input id="gamer" type="checkbox" name="Gamer" value="yes" %($Gamer%)>
            <label for="gamer">Gamer</label>
            <input id="language_learning" type="checkbox" name="Language_learning" value="yes" %($Language_learning%)>
            <label for="language_learning">Language learning</label>
            <input id="lgbtqia" type="checkbox" name="LGBTQIA____" value="yes" %($LGBTQIA____%)>
            <label for="lgbtqia">LGBTQIA+</label>
            <input id="military" type="checkbox" name="Military" value="yes" %($Military%)>
            <label for="military">Military</label>
            <input id="nature" type="checkbox" name="Nature" value="yes" %($Nature%)>
            <label for="nature">Nature</label>
            <input id="sign_language" type="checkbox" name="Sign_language" value="yes" %($Sign_language%)>
            <label for="sign_language">Sign language</label>
            <input id="spiritual" type="checkbox" name="Spiritual" value="yes" %($Spiritual%)>
            <label for="spiritual">Spiritual</label>
            <input id="sports" type="checkbox" name="Sports" value="yes" %($Sports%)>
            <label for="sports">Sports</label>
            <input id="student" type="checkbox" name="Student" value="yes" %($Student%)>
            <label for="student">Student</label>
            <input id="technology" type="checkbox" name="Technology" value="yes" %($Technology%)>
            <label for="technology">Technology</label>
            <input id="travel" type="checkbox" name="Travel" value="yes" %($Travel%)>
            <label for="travel">Travel</label>
            <br /><br />

            <input id="art" type="checkbox" name="Art" value="yes" %($Art%)>
            <label for="art">Art</label>
            <input id="film_video" type="checkbox" name="Film___Video" value="yes" %($Film___Video%)>
            <label for="film_video">Film/Video</label>
            <input id="software_dev" type="checkbox" name="Software_dev" value="yes" %($Software_dev%)>
            <label for="software_dev">Software dev</label>
            <input id="making_vr_avatars" type="checkbox" name="Making_VR_Avatars" value="yes" %($Making_VR_Avatars%)>
            <label for="making_vr_avatars">Making VR Avatars</label>
            <input id="making_vr_worlds" type="checkbox" name="Making_VR_Worlds" value="yes" %($Making_VR_Worlds%)>
            <label for="making_vr_worlds">Making VR Worlds</label>
            <input id="music" type="checkbox" name="Music" value="yes" %($Music%)>
            <label for="music">Music</label>
            <input id="streaming" type="checkbox" name="Streaming" value="yes" %($Streaming%)>
            <label for="streaming">Streaming</label>
            <input id="writing" type="checkbox" name="Writing" value="yes" %($Writing%)>
            <label for="writing">Writing</label>
            <br /><br />

            <input id="action" type="checkbox" name="Action" value="yes" %($Action%)>
            <label for="action">Action</label>
            <input id="adventure" type="checkbox" name="Adventure" value="yes" %($Adventure%)>
            <label for="adventure">Adventure</label>
            <input id="anime" type="checkbox" name="Anime" value="yes" %($Anime%)>
            <label for="anime">Anime</label>
            <input id="cartoon" type="checkbox" name="Cartoon" value="yes" %($Cartoon%)>
            <label for="cartoon">Cartoon</label>
            <input id="comedy" type="checkbox" name="Comedy" value="yes" %($Comedy%)>
            <label for="comedy">Comedy</label>
            <input id="documentary" type="checkbox" name="Documentary" value="yes" %($Documentary%)>
            <label for="documentary">Documentary</label>
            <input id="fantasy" type="checkbox" name="Fantasy" value="yes" %($Fantasy%)>
            <label for="fantasy">Fantasy</label>
            <input id="historical" type="checkbox" name="Historical" value="yes" %($Historical%)>
            <label for="historical">Historical</label>
            <input id="horror" type="checkbox" name="Horror" value="yes" %($Horror%)>
            <label for="horror">Horror</label>
            <input id="mystery" type="checkbox" name="Mystery" value="yes" %($Mystery%)>
            <label for="mystery">Mystery</label>
            <input id="sci_fi" type="checkbox" name="Sci__fi" value="yes" %($Sci__fi%)>
            <label for="sci_fi">Sci-fi</label>
            <input id="superhero" type="checkbox" name="Superhero" value="yes" %($Superhero%)>
            <label for="superhero">Superhero</label>
            <br /><br />

            <input id="board_games" type="checkbox" name="Board_games" value="yes" %($Board_games%)>
            <label for="board_games">Board games</label>
            <input id="driving_simulation" type="checkbox" name="Driving_simulation" value="yes" %($Driving_simulation%)>
            <label for="driving_simulation">Driving simulation</label>
            <input id="esports" type="checkbox" name="eSports" value="yes" %($eSports%)>
            <label for="esports">eSports</label>
            <input id="first_person_shooter" type="checkbox" name="First__person_shooter" value="yes" %($First__person_shooter%)>
            <label for="first_person_shooter">First-person shooter</label>
            <input id="flying_simulation" type="checkbox" name="Flying_simulation" value="yes" %($Flying_simulation%)>
            <label for="flying_simulation">Flying simulation</label>
            <input id="indie" type="checkbox" name="Indie" value="yes" %($Indie%)>
            <label for="indie">Indie</label>
            <input id="mmo" type="checkbox" name="MMO" value="yes" %($MMO%)>
            <label for="mmo">MMO</label>
            <input id="moba" type="checkbox" name="MOBA" value="yes" %($MOBA%)>
            <label for="moba">MOBA</label>
            <input id="puzzle" type="checkbox" name="Puzzle" value="yes" %($Puzzle%)>
            <label for="puzzle">Puzzle</label>
            <input id="rhythm" type="checkbox" name="Rhythm" value="yes" %($Rhythm%)>
            <label for="rhythm">Rhythm</label>
            <input id="rpg" type="checkbox" name="RPG" value="yes" %($RPG%)>
            <label for="rpg">RPG</label>
            <input id="sports_simulation" type="checkbox" name="Sports_simulation" value="yes" %($Sports_simulation%)>
            <label for="sports_simulation">Sports simulation</label>
            <input id="strategy" type="checkbox" name="Strategy" value="yes" %($Strategy%)>
            <label for="strategy">Strategy</label>
            <br /><br />

            <input id="clubbing" type="checkbox" name="Clubbing" value="yes" %($Clubbing%)>
            <label for="clubbing">Clubbing</label>
            <input id="concerts" type="checkbox" name="Concerts" value="yes" %($Concerts%)>
            <label for="concerts">Concerts</label>
            <input id="dancing" type="checkbox" name="Dancing" value="yes" %($Dancing%)>
            <label for="dancing">Dancing</label>
            <input id="exploring_worlds" type="checkbox" name="Exploring_worlds" value="yes" %($Exploring_worlds%)>
            <label for="exploring_worlds">Exploring worlds</label>
            <input id="just_chilling" type="checkbox" name="Just_chilling" value="yes" %($Just_chilling%)>
            <label for="just_chilling">Just chilling</label>
            <input id="karaoke" type="checkbox" name="Karaoke" value="yes" %($Karaoke%)>
            <label for="karaoke">Karaoke</label>
            <input id="movies_videos" type="checkbox" name="Movies___Videos" value="yes" %($Movies___Videos%)>
            <label for="movies_videos">Movies/Videos</label>
            <input id="roleplaying" type="checkbox" name="Roleplaying" value="yes" %($Roleplaying%)>
            <label for="roleplaying">Roleplaying</label>
            <input id="social_games" type="checkbox" name="Social_games" value="yes" %($Social_games%)>
            <label for="social_games">Social games</label>
            <input id="virtual_bars_pubs" type="checkbox" name="Virtual_Bars___Pubs" value="yes" %($Virtual_Bars___Pubs%)>
            <label for="virtual_bars_pubs">Virtual Bars/Pubs</label>
        </div>

        <button type="submit" class="btn btn-mango">Add/update</button>
    </form>
</div>

<div class="box">
    <h1>Games</h1>

%   for (game = `{redis graph read 'MATCH (g:game) RETURN g.name ORDER BY g.name'}) {
        <h2 style="font-family: brandon-grotesque, sans-serif">%($game%)</h2>
        <p>Type: %(`{redis graph read 'MATCH (g:game {name: '''$game'''}) RETURN g.type'}%)</p>
        <p>Platform(s): %(`{redis graph read 'MATCH (g:game {name: '''$game'''})-[:SUPPORTS]->(p:platform) RETURN p.name'}%)</p>
        <p>Interest(s): %(`{redis graph read 'MATCH (g:game {name: '''$game'''})-[:TAGGED]->(t:tag) RETURN t.name'}%)</p>
%   }
</div>
