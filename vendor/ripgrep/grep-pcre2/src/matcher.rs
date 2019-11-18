use std::collections::HashMap;

use grep_matcher::{Captures, Match, Matcher};
use pcre2::bytes::{CaptureLocations, Regex, RegexBuilder};

use error::Error;

/// A builder for configuring the compilation of a PCRE2 regex.
#[derive(Clone, Debug)]
pub struct RegexMatcherBuilder {
    builder: RegexBuilder,
    case_smart: bool,
    word: bool,
}

impl RegexMatcherBuilder {
    /// Create a new matcher builder with a default configuration.
    pub fn new() -> RegexMatcherBuilder {
        RegexMatcherBuilder {
            builder: RegexBuilder::new(),
            case_smart: false,
            word: false,
        }
    }

    /// Compile the given pattern into a PCRE matcher using the current
    /// configuration.
    ///
    /// If there was a problem compiling the pattern, then an error is
    /// returned.
    pub fn build(&self, pattern: &str) -> Result<RegexMatcher, Error> {
        let mut builder = self.builder.clone();
        if self.case_smart && !has_uppercase_literal(pattern) {
            builder.caseless(true);
        }
        let res =
            if self.word {
                let pattern = format!(r"(?<!\w)(?:{})(?!\w)", pattern);
                builder.build(&pattern)
            } else {
                builder.build(pattern)
            };
        res.map_err(Error::regex).map(|regex| {
            let mut names = HashMap::new();
            for (i, name) in regex.capture_names().iter().enumerate() {
                if let Some(ref name) = *name {
                    names.insert(name.to_string(), i);
                }
            }
            RegexMatcher { regex, names }
        })
    }

    /// Enables case insensitive matching.
    ///
    /// If the `utf` option is also set, then Unicode case folding is used
    /// to determine case insensitivity. When the `utf` option is not set,
    /// then only standard ASCII case insensitivity is considered.
    ///
    /// This option corresponds to the `i` flag.
    pub fn caseless(&mut self, yes: bool) -> &mut RegexMatcherBuilder {
        self.builder.caseless(yes);
        self
    }

    /// Whether to enable "smart case" or not.
    ///
    /// When smart case is enabled, the builder will automatically enable
    /// case insensitive matching based on how the pattern is written. Namely,
    /// case insensitive mode is enabled when both of the following things
    /// are believed to be true:
    ///
    /// 1. The pattern contains at least one literal character. For example,
    ///    `a\w` contains a literal (`a`) but `\w` does not.
    /// 2. Of the literals in the pattern, none of them are considered to be
    ///    uppercase according to Unicode. For example, `foo\pL` has no
    ///    uppercase literals but `Foo\pL` does.
    ///
    /// Note that the implementation of this is not perfect. Namely, `\p{Ll}`
    /// will prevent case insensitive matching even though it is part of a meta
    /// sequence. This bug will probably never be fixed.
    pub fn case_smart(&mut self, yes: bool) -> &mut RegexMatcherBuilder {
        self.case_smart = yes;
        self
    }

    /// Enables "dot all" matching.
    ///
    /// When enabled, the `.` metacharacter in the pattern matches any
    /// character, include `\n`. When disabled (the default), `.` will match
    /// any character except for `\n`.
    ///
    /// This option corresponds to the `s` flag.
    pub fn dotall(&mut self, yes: bool) -> &mut RegexMatcherBuilder {
        self.builder.dotall(yes);
        self
    }

    /// Enable "extended" mode in the pattern, where whitespace is ignored.
    ///
    /// This option corresponds to the `x` flag.
    pub fn extended(&mut self, yes: bool) -> &mut RegexMatcherBuilder {
        self.builder.extended(yes);
        self
    }

    /// Enable multiline matching mode.
    ///
    /// When enabled, the `^` and `$` anchors will match both at the beginning
    /// and end of a subject string, in addition to matching at the start of
    /// a line and the end of a line. When disabled, the `^` and `$` anchors
    /// will only match at the beginning and end of a subject string.
    ///
    /// This option corresponds to the `m` flag.
    pub fn multi_line(&mut self, yes: bool) -> &mut RegexMatcherBuilder {
        self.builder.multi_line(yes);
        self
    }

    /// Enable matching of CRLF as a line terminator.
    ///
    /// When enabled, anchors such as `^` and `$` will match any of the
    /// following as a line terminator: `\r`, `\n` or `\r\n`.
    ///
    /// This is disabled by default, in which case, only `\n` is recognized as
    /// a line terminator.
    pub fn crlf(&mut self, yes: bool) -> &mut RegexMatcherBuilder {
        self.builder.crlf(yes);
        self
    }

    /// Require that all matches occur on word boundaries.
    ///
    /// Enabling this option is subtly different than putting `\b` assertions
    /// on both sides of your pattern. In particular, a `\b` assertion requires
    /// that one side of it match a word character while the other match a
    /// non-word character. This option, in contrast, merely requires that
    /// one side match a non-word character.
    ///
    /// For example, `\b-2\b` will not match `foo -2 bar` since `-` is not a
    /// word character. However, `-2` with this `word` option enabled will
    /// match the `-2` in `foo -2 bar`.
    pub fn word(&mut self, yes: bool) -> &mut RegexMatcherBuilder {
        self.word = yes;
        self
    }

    /// Enable Unicode matching mode.
    ///
    /// When enabled, the following patterns become Unicode aware: `\b`, `\B`,
    /// `\d`, `\D`, `\s`, `\S`, `\w`, `\W`.
    ///
    /// When set, this implies UTF matching mode. It is not possible to enable
    /// Unicode matching mode without enabling UTF matching mode.
    ///
    /// This is disabled by default.
    pub fn ucp(&mut self, yes: bool) -> &mut RegexMatcherBuilder {
        self.builder.ucp(yes);
        self
    }

    /// Enable UTF matching mode.
    ///
    /// When enabled, characters are treated as sequences of code units that
    /// make up a single codepoint instead of as single bytes. For example,
    /// this will cause `.` to match any single UTF-8 encoded codepoint, where
    /// as when this is disabled, `.` will any single byte (except for `\n` in
    /// both cases, unless "dot all" mode is enabled).
    ///
    /// Note that when UTF matching mode is enabled, every search performed
    /// will do a UTF-8 validation check, which can impact performance. The
    /// UTF-8 check can be disabled via the `disable_utf_check` option, but it
    /// is undefined behavior to enable UTF matching mode and search invalid
    /// UTF-8.
    ///
    /// This is disabled by default.
    pub fn utf(&mut self, yes: bool) -> &mut RegexMatcherBuilder {
        self.builder.utf(yes);
        self
    }

    /// When UTF matching mode is enabled, this will disable the UTF checking
    /// that PCRE2 will normally perform automatically. If UTF matching mode
    /// is not enabled, then this has no effect.
    ///
    /// UTF checking is enabled by default when UTF matching mode is enabled.
    /// If UTF matching mode is enabled and UTF checking is enabled, then PCRE2
    /// will return an error if you attempt to search a subject string that is
    /// not valid UTF-8.
    ///
    /// # Safety
    ///
    /// It is undefined behavior to disable the UTF check in UTF matching mode
    /// and search a subject string that is not valid UTF-8. When the UTF check
    /// is disabled, callers must guarantee that the subject string is valid
    /// UTF-8.
    pub unsafe fn disable_utf_check(&mut self) -> &mut RegexMatcherBuilder {
        self.builder.disable_utf_check();
        self
    }

    /// Enable PCRE2's JIT and return an error if it's not available.
    ///
    /// This generally speeds up matching quite a bit. The downside is that it
    /// can increase the time it takes to compile a pattern.
    ///
    /// If the JIT isn't available or if JIT compilation returns an error, then
    /// regex compilation will fail with the corresponding error.
    ///
    /// This is disabled by default, and always overrides `jit_if_available`.
    pub fn jit(&mut self, yes: bool) -> &mut RegexMatcherBuilder {
        self.builder.jit(yes);
        self
    }

    /// Enable PCRE2's JIT if it's available.
    ///
    /// This generally speeds up matching quite a bit. The downside is that it
    /// can increase the time it takes to compile a pattern.
    ///
    /// If the JIT isn't available or if JIT compilation returns an error,
    /// then a debug message with the error will be emitted and the regex will
    /// otherwise silently fall back to non-JIT matching.
    ///
    /// This is disabled by default, and always overrides `jit`.
    pub fn jit_if_available(&mut self, yes: bool) -> &mut RegexMatcherBuilder {
        self.builder.jit_if_available(yes);
        self
    }

    /// Set the maximum size of PCRE2's JIT stack, in bytes. If the JIT is
    /// not enabled, then this has no effect.
    ///
    /// When `None` is given, no custom JIT stack will be created, and instead,
    /// the default JIT stack is used. When the default is used, its maximum
    /// size is 32 KB.
    ///
    /// When this is set, then a new JIT stack will be created with the given
    /// maximum size as its limit.
    ///
    /// Increasing the stack size can be useful for larger regular expressions.
    ///
    /// By default, this is set to `None`.
    pub fn max_jit_stack_size(
        &mut self,
        bytes: Option<usize>,
    ) -> &mut RegexMatcherBuilder {
        self.builder.max_jit_stack_size(bytes);
        self
    }
}

/// An implementation of the `Matcher` trait using PCRE2.
#[derive(Clone, Debug)]
pub struct RegexMatcher {
    regex: Regex,
    names: HashMap<String, usize>,
}

impl RegexMatcher {
    /// Create a new matcher from the given pattern using the default
    /// configuration.
    pub fn new(pattern: &str) -> Result<RegexMatcher, Error> {
        RegexMatcherBuilder::new().build(pattern)
    }
}

impl Matcher for RegexMatcher {
    type Captures = RegexCaptures;
    type Error = Error;

    fn find_at(
        &self,
        haystack: &[u8],
        at: usize,
    ) -> Result<Option<Match>, Error> {
        Ok(self.regex
            .find_at(haystack, at)
            .map_err(Error::regex)?
            .map(|m| Match::new(m.start(), m.end())))
    }

    fn new_captures(&self) -> Result<RegexCaptures, Error> {
        Ok(RegexCaptures::new(self.regex.capture_locations()))
    }

    fn capture_count(&self) -> usize {
        self.regex.captures_len()
    }

    fn capture_index(&self, name: &str) -> Option<usize> {
        self.names.get(name).map(|i| *i)
    }

    fn try_find_iter<F, E>(
        &self,
        haystack: &[u8],
        mut matched: F,
    ) -> Result<Result<(), E>, Error>
    where F: FnMut(Match) -> Result<bool, E>
    {
        for result in self.regex.find_iter(haystack) {
            let m = result.map_err(Error::regex)?;
            match matched(Match::new(m.start(), m.end())) {
                Ok(true) => continue,
                Ok(false) => return Ok(Ok(())),
                Err(err) => return Ok(Err(err)),
            }
        }
        Ok(Ok(()))
    }

    fn captures_at(
        &self,
        haystack: &[u8],
        at: usize,
        caps: &mut RegexCaptures,
    ) -> Result<bool, Error> {
        Ok(self.regex
           .captures_read_at(&mut caps.locs, haystack, at)
           .map_err(Error::regex)?
           .is_some())
    }
}

/// Represents the match offsets of each capturing group in a match.
///
/// The first, or `0`th capture group, always corresponds to the entire match
/// and is guaranteed to be present when a match occurs. The next capture
/// group, at index `1`, corresponds to the first capturing group in the regex,
/// ordered by the position at which the left opening parenthesis occurs.
///
/// Note that not all capturing groups are guaranteed to be present in a match.
/// For example, in the regex, `(?P<foo>\w)|(?P<bar>\W)`, only one of `foo`
/// or `bar` will ever be set in any given match.
///
/// In order to access a capture group by name, you'll need to first find the
/// index of the group using the corresponding matcher's `capture_index`
/// method, and then use that index with `RegexCaptures::get`.
#[derive(Clone, Debug)]
pub struct RegexCaptures {
    /// Where the locations are stored.
    locs: CaptureLocations,
}

impl Captures for RegexCaptures {
    fn len(&self) -> usize {
        self.locs.len()
    }

    fn get(&self, i: usize) -> Option<Match> {
        self.locs.get(i).map(|(s, e)| Match::new(s, e))
    }
}

impl RegexCaptures {
    pub(crate) fn new(locs: CaptureLocations) -> RegexCaptures {
        RegexCaptures { locs }
    }
}

/// Determine whether the pattern contains an uppercase character which should
/// negate the effect of the smart-case option.
///
/// Ideally we would be able to check the AST in order to correctly handle
/// things like '\p{Ll}' and '\p{Lu}' (which should be treated as explicitly
/// cased), but PCRE doesn't expose enough details for that kind of analysis.
/// For now, our 'good enough' solution is to simply perform a semi-naïve
/// scan of the input pattern and ignore all characters following a '\'. The
/// This at least lets us support the most common cases, like 'foo\w' and
/// 'foo\S', in an intuitive manner.
fn has_uppercase_literal(pattern: &str) -> bool {
    let mut chars = pattern.chars();
    while let Some(c) = chars.next() {
        if c == '\\' {
            chars.next();
        } else if c.is_uppercase() {
            return true;
        }
    }
    false
}

#[cfg(test)]
mod tests {
    use grep_matcher::{LineMatchKind, Matcher};
    use super::*;

    // Test that enabling word matches does the right thing and demonstrate
    // the difference between it and surrounding the regex in `\b`.
    #[test]
    fn word() {
        let matcher = RegexMatcherBuilder::new()
            .word(true)
            .build(r"-2")
            .unwrap();
        assert!(matcher.is_match(b"abc -2 foo").unwrap());

        let matcher = RegexMatcherBuilder::new()
            .word(false)
            .build(r"\b-2\b")
            .unwrap();
        assert!(!matcher.is_match(b"abc -2 foo").unwrap());
    }

    // Test that enabling CRLF permits `$` to match at the end of a line.
    #[test]
    fn line_terminator_crlf() {
        // Test normal use of `$` with a `\n` line terminator.
        let matcher = RegexMatcherBuilder::new()
            .multi_line(true)
            .build(r"abc$")
            .unwrap();
        assert!(matcher.is_match(b"abc\n").unwrap());

        // Test that `$` doesn't match at `\r\n` boundary normally.
        let matcher = RegexMatcherBuilder::new()
            .multi_line(true)
            .build(r"abc$")
            .unwrap();
        assert!(!matcher.is_match(b"abc\r\n").unwrap());

        // Now check the CRLF handling.
        let matcher = RegexMatcherBuilder::new()
            .multi_line(true)
            .crlf(true)
            .build(r"abc$")
            .unwrap();
        assert!(matcher.is_match(b"abc\r\n").unwrap());
    }

    // Test that smart case works.
    #[test]
    fn case_smart() {
        let matcher = RegexMatcherBuilder::new()
            .case_smart(true)
            .build(r"abc")
            .unwrap();
        assert!(matcher.is_match(b"ABC").unwrap());

        let matcher = RegexMatcherBuilder::new()
            .case_smart(true)
            .build(r"aBc")
            .unwrap();
        assert!(!matcher.is_match(b"ABC").unwrap());
    }

    // Test that finding candidate lines works as expected.
    #[test]
    fn candidate_lines() {
        fn is_confirmed(m: LineMatchKind) -> bool {
            match m {
                LineMatchKind::Confirmed(_) => true,
                _ => false,
            }
        }

        let matcher = RegexMatcherBuilder::new()
            .build(r"\wfoo\s")
            .unwrap();
        let m = matcher.find_candidate_line(b"afoo ").unwrap().unwrap();
        assert!(is_confirmed(m));
    }
}
