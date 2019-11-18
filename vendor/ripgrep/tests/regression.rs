use crate::hay::SHERLOCK;
use crate::util::{Dir, TestCommand, sort_lines};

// See: https://github.com/BurntSushi/ripgrep/issues/16
rgtest!(r16, |dir: Dir, mut cmd: TestCommand| {
    dir.create_dir(".git");
    dir.create(".gitignore", "ghi/");
    dir.create_dir("ghi");
    dir.create_dir("def/ghi");
    dir.create("ghi/toplevel.txt", "xyz");
    dir.create("def/ghi/subdir.txt", "xyz");

    cmd.arg("xyz").assert_err();
});

// See: https://github.com/BurntSushi/ripgrep/issues/25
rgtest!(r25, |dir: Dir, mut cmd: TestCommand| {
    dir.create_dir(".git");
    dir.create(".gitignore", "/llvm/");
    dir.create_dir("src/llvm");
    dir.create("src/llvm/foo", "test");

    cmd.arg("test");
    eqnice!("src/llvm/foo:test\n", cmd.stdout());

    cmd.current_dir(dir.path().join("src"));
    eqnice!("llvm/foo:test\n", cmd.stdout());
});

// See: https://github.com/BurntSushi/ripgrep/issues/30
rgtest!(r30, |dir: Dir, mut cmd: TestCommand| {
    dir.create(".gitignore", "vendor/**\n!vendor/manifest");
    dir.create_dir("vendor");
    dir.create("vendor/manifest", "test");

    eqnice!("vendor/manifest:test\n", cmd.arg("test").stdout());
});

// See: https://github.com/BurntSushi/ripgrep/issues/49
rgtest!(r49, |dir: Dir, mut cmd: TestCommand| {
    dir.create(".gitignore", "foo/bar");
    dir.create_dir("test/foo/bar");
    dir.create("test/foo/bar/baz", "test");

    cmd.arg("xyz").assert_err();
});

// See: https://github.com/BurntSushi/ripgrep/issues/50
rgtest!(r50, |dir: Dir, mut cmd: TestCommand| {
    dir.create(".gitignore", "XXX/YYY/");
    dir.create_dir("abc/def/XXX/YYY");
    dir.create_dir("ghi/XXX/YYY");
    dir.create("abc/def/XXX/YYY/bar", "test");
    dir.create("ghi/XXX/YYY/bar", "test");

    cmd.arg("xyz").assert_err();
});

// See: https://github.com/BurntSushi/ripgrep/issues/64
rgtest!(r64, |dir: Dir, mut cmd: TestCommand| {
    dir.create_dir("dir");
    dir.create_dir("foo");
    dir.create("dir/abc", "");
    dir.create("foo/abc", "");

    eqnice!("foo/abc\n", cmd.arg("--files").arg("foo").stdout());
});

// See: https://github.com/BurntSushi/ripgrep/issues/65
rgtest!(r65, |dir: Dir, mut cmd: TestCommand| {
    dir.create_dir(".git");
    dir.create(".gitignore", "a/");
    dir.create_dir("a");
    dir.create("a/foo", "xyz");
    dir.create("a/bar", "xyz");

    cmd.arg("xyz").assert_err();
});

// See: https://github.com/BurntSushi/ripgrep/issues/67
rgtest!(r67, |dir: Dir, mut cmd: TestCommand| {
    dir.create_dir(".git");
    dir.create(".gitignore", "/*\n!/dir");
    dir.create_dir("dir");
    dir.create_dir("foo");
    dir.create("foo/bar", "test");
    dir.create("dir/bar", "test");

    eqnice!("dir/bar:test\n", cmd.arg("test").stdout());
});

// See: https://github.com/BurntSushi/ripgrep/issues/87
rgtest!(r87, |dir: Dir, mut cmd: TestCommand| {
    dir.create_dir(".git");
    dir.create(".gitignore", "foo\n**no-vcs**");
    dir.create("foo", "test");

    cmd.arg("test").assert_err();
});

// See: https://github.com/BurntSushi/ripgrep/issues/90
rgtest!(r90, |dir: Dir, mut cmd: TestCommand| {
    dir.create_dir(".git");
    dir.create(".gitignore", "!.foo");
    dir.create(".foo", "test");

    eqnice!(".foo:test\n", cmd.arg("test").stdout());
});

// See: https://github.com/BurntSushi/ripgrep/issues/93
rgtest!(r93, |dir: Dir, mut cmd: TestCommand| {
    dir.create("foo", "192.168.1.1");

    eqnice!("foo:192.168.1.1\n", cmd.arg(r"(\d{1,3}\.){3}\d{1,3}").stdout());
});

// See: https://github.com/BurntSushi/ripgrep/issues/99
rgtest!(r99, |dir: Dir, mut cmd: TestCommand| {
    dir.create("foo1", "test");
    dir.create("foo2", "zzz");
    dir.create("bar", "test");

    eqnice!(
        sort_lines("bar\ntest\n\nfoo1\ntest\n"),
        sort_lines(&cmd.arg("-j1").arg("--heading").arg("test").stdout())
    );
});

// See: https://github.com/BurntSushi/ripgrep/issues/105
rgtest!(r105_part1, |dir: Dir, mut cmd: TestCommand| {
    dir.create("foo", "zztest");

    eqnice!("foo:1:3:zztest\n", cmd.arg("--vimgrep").arg("test").stdout());
});

// See: https://github.com/BurntSushi/ripgrep/issues/105
rgtest!(r105_part2, |dir: Dir, mut cmd: TestCommand| {
    dir.create("foo", "zztest");

    eqnice!("foo:1:3:zztest\n", cmd.arg("--column").arg("test").stdout());
});

// See: https://github.com/BurntSushi/ripgrep/issues/127
rgtest!(r127, |dir: Dir, mut cmd: TestCommand| {
    // Set up a directory hierarchy like this:
    //
    // .gitignore
    // foo/
    //   sherlock
    //   watson
    //
    // Where `.gitignore` contains `foo/sherlock`.
    //
    // ripgrep should ignore 'foo/sherlock' giving us results only from
    // 'foo/watson' but on Windows ripgrep will include both 'foo/sherlock' and
    // 'foo/watson' in the search results.
    dir.create_dir(".git");
    dir.create(".gitignore", "foo/sherlock\n");
    dir.create_dir("foo");
    dir.create("foo/sherlock", SHERLOCK);
    dir.create("foo/watson", SHERLOCK);

    let expected = "\
foo/watson:For the Doctor Watsons of this world, as opposed to the Sherlock
foo/watson:be, to a very large extent, the result of luck. Sherlock Holmes
";
    assert_eq!(expected, cmd.arg("Sherlock").stdout());
});

// See: https://github.com/BurntSushi/ripgrep/issues/128
rgtest!(r128, |dir: Dir, mut cmd: TestCommand| {
    dir.create_bytes("foo", b"01234567\x0b\n\x0b\n\x0b\n\x0b\nx");

    eqnice!("foo:5:x\n", cmd.arg("-n").arg("x").stdout());
});

// See: https://github.com/BurntSushi/ripgrep/issues/131
//
// TODO(burntsushi): Darwin doesn't like this test for some reason. Probably
// due to the weird file path.
#[cfg(not(target_os = "macos"))]
rgtest!(r131, |dir: Dir, mut cmd: TestCommand| {
    dir.create_dir(".git");
    dir.create(".gitignore", "TopÑapa");
    dir.create("TopÑapa", "test");

    cmd.arg("test").assert_err();
});

// See: https://github.com/BurntSushi/ripgrep/issues/137
//
// TODO(burntsushi): Figure out how to make this test work on Windows. Right
// now it gives "access denied" errors when trying to create a file symlink.
// For now, disable test on Windows.
#[cfg(not(windows))]
rgtest!(r137, |dir: Dir, mut cmd: TestCommand| {
    dir.create("sherlock", SHERLOCK);
    dir.link_file("sherlock", "sym1");
    dir.link_file("sherlock", "sym2");

    let expected = "\
./sherlock:For the Doctor Watsons of this world, as opposed to the Sherlock
./sherlock:be, to a very large extent, the result of luck. Sherlock Holmes
sym1:For the Doctor Watsons of this world, as opposed to the Sherlock
sym1:be, to a very large extent, the result of luck. Sherlock Holmes
sym2:For the Doctor Watsons of this world, as opposed to the Sherlock
sym2:be, to a very large extent, the result of luck. Sherlock Holmes
";
    cmd.arg("-j1").arg("Sherlock").arg("./").arg("sym1").arg("sym2");
    eqnice!(expected, cmd.stdout());
});

// See: https://github.com/BurntSushi/ripgrep/issues/156
rgtest!(r156, |dir: Dir, mut cmd: TestCommand| {
    let expected = r#"#parse('widgets/foo_bar_macros.vm')
#parse ( 'widgets/mobile/foo_bar_macros.vm' )
#parse ("widgets/foobarhiddenformfields.vm")
#parse ( "widgets/foo_bar_legal.vm" )
#include( 'widgets/foo_bar_tips.vm' )
#include('widgets/mobile/foo_bar_macros.vm')
#include ("widgets/mobile/foo_bar_resetpw.vm")
#parse('widgets/foo-bar-macros.vm')
#parse ( 'widgets/mobile/foo-bar-macros.vm' )
#parse ("widgets/foo-bar-hiddenformfields.vm")
#parse ( "widgets/foo-bar-legal.vm" )
#include( 'widgets/foo-bar-tips.vm' )
#include('widgets/mobile/foo-bar-macros.vm')
#include ("widgets/mobile/foo-bar-resetpw.vm")
"#;
    dir.create("testcase.txt", expected);

    cmd.arg("-N");
    cmd.arg(r#"#(?:parse|include)\s*\(\s*(?:"|')[./A-Za-z_-]+(?:"|')"#);
    cmd.arg("testcase.txt");
    eqnice!(expected, cmd.stdout());
});

// See: https://github.com/BurntSushi/ripgrep/issues/184
rgtest!(r184, |dir: Dir, mut cmd: TestCommand| {
    dir.create(".gitignore", ".*");
    dir.create_dir("foo/bar");
    dir.create("foo/bar/baz", "test");

    cmd.arg("test");
    eqnice!("foo/bar/baz:test\n", cmd.stdout());

    cmd.current_dir(dir.path().join("./foo/bar"));
    eqnice!("baz:test\n", cmd.stdout());
});

// See: https://github.com/BurntSushi/ripgrep/issues/199
rgtest!(r199, |dir: Dir, mut cmd: TestCommand| {
    dir.create("foo", "tEsT");

    eqnice!("foo:tEsT\n", cmd.arg("--smart-case").arg(r"\btest\b").stdout());
});

// See: https://github.com/BurntSushi/ripgrep/issues/206
rgtest!(r206, |dir: Dir, mut cmd: TestCommand| {
    dir.create_dir("foo");
    dir.create("foo/bar.txt", "test");

    cmd.arg("test").arg("-g").arg("*.txt");
    eqnice!("foo/bar.txt:test\n", cmd.stdout());
});

// See: https://github.com/BurntSushi/ripgrep/issues/210
#[cfg(unix)]
rgtest!(r210, |dir: Dir, mut cmd: TestCommand| {
    use std::ffi::OsStr;
    use std::os::unix::ffi::OsStrExt;

    let badutf8 = OsStr::from_bytes(&b"foo\xffbar"[..]);

    // APFS does not support creating files with invalid UTF-8 bytes.
    // https://github.com/BurntSushi/ripgrep/issues/559
    if dir.try_create(badutf8, "test").is_ok() {
        cmd.arg("-H").arg("test").arg(badutf8);
        assert_eq!(b"foo\xffbar:test\n".to_vec(), cmd.output().stdout);
    }
});

// See: https://github.com/BurntSushi/ripgrep/issues/228
rgtest!(r228, |dir: Dir, mut cmd: TestCommand| {
    dir.create_dir("foo");

    cmd.arg("--ignore-file").arg("foo").arg("test").assert_err();
});

// See: https://github.com/BurntSushi/ripgrep/issues/229
rgtest!(r229, |dir: Dir, mut cmd: TestCommand| {
    dir.create("foo", "economie");

    cmd.arg("-S").arg("[E]conomie").assert_err();
});

// See: https://github.com/BurntSushi/ripgrep/issues/251
rgtest!(r251, |dir: Dir, mut cmd: TestCommand| {
    dir.create("foo", "привет\nПривет\nПрИвЕт");

    let expected = "foo:привет\nfoo:Привет\nfoo:ПрИвЕт\n";
    eqnice!(expected, cmd.arg("-i").arg("привет").stdout());
});

// See: https://github.com/BurntSushi/ripgrep/issues/256
#[cfg(not(windows))]
rgtest!(r256, |dir: Dir, mut cmd: TestCommand| {
    dir.create_dir("bar");
    dir.create("bar/baz", "test");
    dir.link_dir("bar", "foo");

    eqnice!("foo/baz:test\n", cmd.arg("test").arg("foo").stdout());
});

// See: https://github.com/BurntSushi/ripgrep/issues/256
#[cfg(not(windows))]
rgtest!(r256_j1, |dir: Dir, mut cmd: TestCommand| {
    dir.create_dir("bar");
    dir.create("bar/baz", "test");
    dir.link_dir("bar", "foo");

    eqnice!("foo/baz:test\n", cmd.arg("-j1").arg("test").arg("foo").stdout());
});

// See: https://github.com/BurntSushi/ripgrep/issues/270
rgtest!(r270, |dir: Dir, mut cmd: TestCommand| {
    dir.create("foo", "-test");

    cmd.arg("-e").arg("-test");
    eqnice!("foo:-test\n", cmd.stdout());
});

// See: https://github.com/BurntSushi/ripgrep/issues/279
rgtest!(r279, |dir: Dir, mut cmd: TestCommand| {
    dir.create("foo", "test");

    eqnice!("", cmd.arg("-q").arg("test").stdout());
});

// See: https://github.com/BurntSushi/ripgrep/issues/391
rgtest!(r391, |dir: Dir, mut cmd: TestCommand| {
    dir.create_dir(".git");
    dir.create("lock", "");
    dir.create("bar.py", "");
    dir.create(".git/packed-refs", "");
    dir.create(".git/description", "");

    cmd.args(&[
        "--no-ignore", "--hidden", "--follow", "--files",
        "--glob",
        "!{.git,node_modules,plugged}/**",
        "--glob",
        "*.{js,json,php,md,styl,scss,sass,pug,html,config,py,cpp,c,go,hs}",
    ]);
    eqnice!("bar.py\n", cmd.stdout());
});

// See: https://github.com/BurntSushi/ripgrep/issues/405
rgtest!(r405, |dir: Dir, mut cmd: TestCommand| {
    dir.create_dir("foo/bar");
    dir.create_dir("bar/foo");
    dir.create("foo/bar/file1.txt", "test");
    dir.create("bar/foo/file2.txt", "test");

    cmd.arg("-g").arg("!/foo/**").arg("test");
    eqnice!("bar/foo/file2.txt:test\n", cmd.stdout());
});

// See: https://github.com/BurntSushi/ripgrep/issues/428
#[cfg(not(windows))]
rgtest!(r428_color_context_path, |dir: Dir, mut cmd: TestCommand| {
    dir.create("sherlock", "foo\nbar");
    cmd.args(&[
        "-A1", "-H", "--no-heading", "-N",
        "--colors=match:none", "--color=always",
        "foo",
    ]);

    let expected = format!(
        "{colored_path}:foo\n{colored_path}-bar\n",
        colored_path=
            "\x1b\x5b\x30\x6d\x1b\x5b\x33\x35\x6dsherlock\x1b\x5b\x30\x6d"
    );
    eqnice!(expected, cmd.stdout());
});

// See: https://github.com/BurntSushi/ripgrep/issues/428
rgtest!(r428_unrecognized_style, |_: Dir, mut cmd: TestCommand| {
    cmd.arg("--colors=match:style:").arg("Sherlock");
    cmd.assert_err();

    let output = cmd.cmd().output().unwrap();
    let stderr = String::from_utf8_lossy(&output.stderr);
    let expected = "\
unrecognized style attribute ''. Choose from: nobold, bold, nointense, \
intense, nounderline, underline.
";
    eqnice!(expected, stderr);
});

// See: https://github.com/BurntSushi/ripgrep/issues/451
rgtest!(r451_only_matching_as_in_issue, |dir: Dir, mut cmd: TestCommand| {
    dir.create("digits.txt", "1 2 3\n");
    cmd.arg("--only-matching").arg(r"[0-9]+").arg("digits.txt");

    let expected = "\
1
2
3
";
    eqnice!(expected, cmd.stdout());
});

// See: https://github.com/BurntSushi/ripgrep/issues/451
rgtest!(r451_only_matching, |dir: Dir, mut cmd: TestCommand| {
    dir.create("digits.txt", "1 2 3\n123\n");
    cmd.args(&[
        "--only-matching", "--column", r"[0-9]", "digits.txt",
    ]);

    let expected = "\
1:1:1
1:3:2
1:5:3
2:1:1
2:2:2
2:3:3
";
    eqnice!(expected, cmd.stdout());
});

// See: https://github.com/BurntSushi/ripgrep/issues/483
rgtest!(r483_matching_no_stdout, |dir: Dir, mut cmd: TestCommand| {
    dir.create("file.py", "");
    cmd.arg("--quiet").arg("--files").arg("--glob").arg("*.py");
    eqnice!("", cmd.stdout());
});

// See: https://github.com/BurntSushi/ripgrep/issues/483
rgtest!(r483_non_matching_exit_code, |dir: Dir, mut cmd: TestCommand| {
    dir.create("file.rs", "");
    cmd.arg("--quiet").arg("--files").arg("--glob").arg("*.py");
    cmd.assert_err();
});

// See: https://github.com/BurntSushi/ripgrep/issues/493
rgtest!(r493, |dir: Dir, mut cmd: TestCommand| {
    dir.create("input.txt", "peshwaship 're seminomata");

    cmd.arg("-o").arg(r"\b 're \b").arg("input.txt");
    assert_eq!(" 're \n", cmd.stdout());
});

// See: https://github.com/BurntSushi/ripgrep/issues/506
rgtest!(r506_word_not_parenthesized, |dir: Dir, mut cmd: TestCommand| {
    dir.create("wb.txt", "min minimum amin\nmax maximum amax");
    cmd.arg("-w").arg("-o").arg("min|max").arg("wb.txt");
    eqnice!("min\nmax\n", cmd.stdout());
});

// See: https://github.com/BurntSushi/ripgrep/issues/553
rgtest!(r553_switch, |dir: Dir, mut cmd: TestCommand| {
    dir.create("sherlock", SHERLOCK);

    let expected = "\
sherlock:For the Doctor Watsons of this world, as opposed to the Sherlock
sherlock:be, to a very large extent, the result of luck. Sherlock Holmes
";
    cmd.arg("-i").arg("sherlock");
    eqnice!(expected, cmd.stdout());

    // Repeat the `i` flag to make sure everything still works.
    eqnice!(expected, cmd.arg("-i").stdout());
});

rgtest!(r553_flag, |dir: Dir, mut cmd: TestCommand| {
    dir.create("sherlock", SHERLOCK);

    let expected = "\
For the Doctor Watsons of this world, as opposed to the Sherlock
Holmeses, success in the province of detective work must always
--
but Doctor Watson has to have it taken out for him and dusted,
and exhibited clearly, with a label attached.
";
    cmd.arg("-C").arg("1").arg(r"world|attached").arg("sherlock");
    eqnice!(expected, cmd.stdout());

    let expected = "\
For the Doctor Watsons of this world, as opposed to the Sherlock
and exhibited clearly, with a label attached.
";
    eqnice!(expected, cmd.arg("-C").arg("0").stdout());
});

// See: https://github.com/BurntSushi/ripgrep/issues/568
rgtest!(r568_leading_hyphen_option_args, |dir: Dir, mut cmd: TestCommand| {
    dir.create("file", "foo bar -baz\n");
    cmd.arg("-e-baz").arg("-e").arg("-baz").arg("file");
    eqnice!("foo bar -baz\n", cmd.stdout());

    let mut cmd = dir.command();
    cmd.arg("-rni").arg("bar").arg("file");
    eqnice!("foo ni -baz\n", cmd.stdout());

    let mut cmd = dir.command();
    cmd.arg("-r").arg("-n").arg("-i").arg("bar").arg("file");
    eqnice!("foo -n -baz\n", cmd.stdout());
});

// See: https://github.com/BurntSushi/ripgrep/issues/599
//
// This test used to check that we emitted color escape sequences even for
// empty matches, but with the addition of the JSON output format, clients no
// longer need to rely on escape sequences to parse matches. Therefore, we no
// longer emit useless escape sequences.
rgtest!(r599, |dir: Dir, mut cmd: TestCommand| {
    dir.create("input.txt", "\n\ntest\n");
    cmd.args(&[
        "--color", "ansi",
        "--colors", "path:none",
        "--colors", "line:none",
        "--colors", "match:fg:red",
        "--colors", "match:style:nobold",
        "--line-number",
        r"^$",
        "input.txt",
    ]);

    let expected = "\
[0m1[0m:
[0m2[0m:
";
    eqnice_repr!(expected, cmd.stdout());
});

// See: https://github.com/BurntSushi/ripgrep/issues/693
rgtest!(r693_context_in_contextless_mode, |dir: Dir, mut cmd: TestCommand| {
    dir.create("foo", "xyz\n");
    dir.create("bar", "xyz\n");

    cmd.arg("-C1").arg("-c").arg("--sort-files").arg("xyz");
    eqnice!("bar:1\nfoo:1\n", cmd.stdout());
});

// See: https://github.com/BurntSushi/ripgrep/issues/807
rgtest!(r807, |dir: Dir, mut cmd: TestCommand| {
    dir.create_dir(".git");
    dir.create(".gitignore", ".a/b");
    dir.create_dir(".a/b");
    dir.create_dir(".a/c");
    dir.create(".a/b/file", "test");
    dir.create(".a/c/file", "test");

    eqnice!(".a/c/file:test\n", cmd.arg("--hidden").arg("test").stdout());
});

// See: https://github.com/BurntSushi/ripgrep/issues/900
rgtest!(r900, |dir: Dir, mut cmd: TestCommand| {
    dir.create("sherlock", SHERLOCK);
    dir.create("pat", "");

    cmd.arg("-fpat").arg("sherlock").assert_err();
});

// See: https://github.com/BurntSushi/ripgrep/issues/1064
rgtest!(r1064, |dir: Dir, mut cmd: TestCommand| {
    dir.create("input", "abc");
    eqnice!("input:abc\n", cmd.arg("a(.*c)").stdout());
});

// See: https://github.com/BurntSushi/ripgrep/issues/1174
rgtest!(r1098, |dir: Dir, mut cmd: TestCommand| {
    dir.create_dir(".git");
    dir.create(".gitignore", "a**b");
    dir.create("afoob", "test");
    cmd.arg("test").assert_err();
});

// See: https://github.com/BurntSushi/ripgrep/issues/1130
rgtest!(r1130, |dir: Dir, mut cmd: TestCommand| {
    dir.create("foo", "test");
    eqnice!(
        "foo\n",
        cmd.arg("--files-with-matches").arg("test").arg("foo").stdout()
    );

    let mut cmd = dir.command();
    eqnice!(
        "foo\n",
        cmd.arg("--files-without-match").arg("nada").arg("foo").stdout()
    );
});

// See: https://github.com/BurntSushi/ripgrep/issues/1159
rgtest!(r1159_invalid_flag, |_: Dir, mut cmd: TestCommand| {
    cmd.arg("--wat").assert_exit_code(2);
});

// See: https://github.com/BurntSushi/ripgrep/issues/1159
rgtest!(r1159_exit_status, |dir: Dir, _: TestCommand| {
    dir.create("foo", "test");

    // search with a match gets 0 exit status.
    let mut cmd = dir.command();
    cmd.arg("test").assert_exit_code(0);

    // search with --quiet and a match gets 0 exit status.
    let mut cmd = dir.command();
    cmd.arg("-q").arg("test").assert_exit_code(0);

    // search with a match and an error gets 2 exit status.
    let mut cmd = dir.command();
    cmd.arg("test").arg("no-file").assert_exit_code(2);

    // search with a match in --quiet mode and an error gets 0 exit status.
    let mut cmd = dir.command();
    cmd.arg("-q").arg("test").arg("foo").arg("no-file").assert_exit_code(0);

    // search with no match gets 1 exit status.
    let mut cmd = dir.command();
    cmd.arg("nada").assert_exit_code(1);

    // search with --quiet and no match gets 1 exit status.
    let mut cmd = dir.command();
    cmd.arg("-q").arg("nada").assert_exit_code(1);

    // search with no match and an error gets 2 exit status.
    let mut cmd = dir.command();
    cmd.arg("nada").arg("no-file").assert_exit_code(2);

    // search with no match in --quiet mode and an error gets 2 exit status.
    let mut cmd = dir.command();
    cmd.arg("-q").arg("nada").arg("foo").arg("no-file").assert_exit_code(2);
});

// See: https://github.com/BurntSushi/ripgrep/issues/1163
rgtest!(r1163, |dir: Dir, mut cmd: TestCommand| {
    dir.create("bom.txt", "\u{FEFF}test123\ntest123");
    eqnice!(
        "bom.txt:test123\nbom.txt:test123\n",
        cmd.arg("^test123").stdout()
    );
});

// See: https://github.com/BurntSushi/ripgrep/issues/1164
rgtest!(r1164, |dir: Dir, mut cmd: TestCommand| {
    dir.create_dir(".git");
    dir.create(".gitignore", "myfile");
    dir.create("MYFILE", "test");

    cmd.arg("--ignore-file-case-insensitive").arg("test").assert_err();
    eqnice!(
        "MYFILE:test\n",
        cmd.arg("--no-ignore-file-case-insensitive").stdout()
    );
});

// See: https://github.com/BurntSushi/ripgrep/issues/1173
rgtest!(r1173, |dir: Dir, mut cmd: TestCommand| {
    dir.create_dir(".git");
    dir.create(".gitignore", "**");
    dir.create("foo", "test");
    cmd.arg("test").assert_err();
});

// See: https://github.com/BurntSushi/ripgrep/issues/1174
rgtest!(r1174, |dir: Dir, mut cmd: TestCommand| {
    dir.create_dir(".git");
    dir.create(".gitignore", "**/**/*");
    dir.create_dir("a");
    dir.create("a/foo", "test");
    cmd.arg("test").assert_err();
});

// See: https://github.com/BurntSushi/ripgrep/issues/1176
rgtest!(r1176_literal_file, |dir: Dir, mut cmd: TestCommand| {
    dir.create("patterns", "foo(bar\n");
    dir.create("test", "foo(bar");

    eqnice!(
        "foo(bar\n",
        cmd.arg("-F").arg("-f").arg("patterns").arg("test").stdout()
    );
});

// See: https://github.com/BurntSushi/ripgrep/issues/1176
rgtest!(r1176_line_regex, |dir: Dir, mut cmd: TestCommand| {
    dir.create("patterns", "foo\n");
    dir.create("test", "foobar\nfoo\nbarfoo\n");

    eqnice!(
        "foo\n",
        cmd.arg("-x").arg("-f").arg("patterns").arg("test").stdout()
    );
});

// See: https://github.com/BurntSushi/ripgrep/issues/1203
rgtest!(r1203_reverse_suffix_literal, |dir: Dir, _: TestCommand| {
    dir.create("test", "153.230000\n");

    let mut cmd = dir.command();
    eqnice!("153.230000\n", cmd.arg(r"\d\d\d00").arg("test").stdout());

    let mut cmd = dir.command();
    eqnice!("153.230000\n", cmd.arg(r"\d\d\d000").arg("test").stdout());
});

// See: https://github.com/BurntSushi/ripgrep/issues/1223
rgtest!(r1223_no_dir_check_for_default_path, |dir: Dir, mut cmd: TestCommand| {
    dir.create_dir("-");
    dir.create("a.json", "{}");
    dir.create("a.txt", "some text");

    eqnice!(
        "a.json\na.txt\n",
        sort_lines(&cmd.arg("a").pipe(b"a.json\na.txt"))
    );
});

// See: https://github.com/BurntSushi/ripgrep/issues/1259
rgtest!(r1259_drop_last_byte_nonl, |dir: Dir, mut cmd: TestCommand| {
    dir.create("patterns-nonl", "[foo]");
    dir.create("patterns-nl", "[foo]\n");
    dir.create("test", "fz");

    eqnice!("fz\n", cmd.arg("-f").arg("patterns-nonl").arg("test").stdout());
    cmd = dir.command();
    eqnice!("fz\n", cmd.arg("-f").arg("patterns-nl").arg("test").stdout());
});

// See: https://github.com/BurntSushi/ripgrep/issues/1334
rgtest!(r1334_crazy_literals, |dir: Dir, mut cmd: TestCommand| {
    dir.create("patterns", &"1.208.0.0/12\n".repeat(40));
    dir.create("corpus", "1.208.0.0/12\n");
    eqnice!(
        "1.208.0.0/12\n",
        cmd.arg("-Ff").arg("patterns").arg("corpus").stdout()
    );
});
