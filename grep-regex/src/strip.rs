use grep_matcher::LineTerminator;
use regex_syntax::hir::{self, Hir, HirKind};

use error::{Error, ErrorKind};

/// Return an HIR that is guaranteed to never match the given line terminator,
/// if possible.
///
/// If the transformation isn't possible, then an error is returned.
///
/// In general, if a literal line terminator occurs anywhere in the HIR, then
/// this will return an error. However, if the line terminator occurs within
/// a character class with at least one other character (that isn't also a line
/// terminator), then the line terminator is simply stripped from that class.
///
/// If the given line terminator is not ASCII, then this function returns an
/// error.
pub fn strip_from_match(
    expr: Hir,
    line_term: LineTerminator,
) -> Result<Hir, Error> {
    if line_term.is_crlf() {
        let expr1 = strip_from_match_ascii(expr, b'\r')?;
        strip_from_match_ascii(expr1, b'\n')
    } else {
        let b = line_term.as_byte();
        if b > 0x7F {
            return Err(Error::new(ErrorKind::InvalidLineTerminator(b)));
        }
        strip_from_match_ascii(expr, b)
    }
}

/// The implementation of strip_from_match. The given byte must be ASCII. This
/// function panics otherwise.
fn strip_from_match_ascii(
    expr: Hir,
    byte: u8,
) -> Result<Hir, Error> {
    assert!(byte <= 0x7F);
    let chr = byte as char;
    assert_eq!(chr.len_utf8(), 1);

    let invalid = || Err(Error::new(ErrorKind::NotAllowed(chr.to_string())));

    Ok(match expr.into_kind() {
        HirKind::Empty => Hir::empty(),
        HirKind::Literal(hir::Literal::Unicode(c)) => {
            if c == chr {
                return invalid();
            }
            Hir::literal(hir::Literal::Unicode(c))
        }
        HirKind::Literal(hir::Literal::Byte(b)) => {
            if b as char == chr {
                return invalid();
            }
            Hir::literal(hir::Literal::Byte(b))
        }
        HirKind::Class(hir::Class::Unicode(mut cls)) => {
            let remove = hir::ClassUnicode::new(Some(
                hir::ClassUnicodeRange::new(chr, chr),
            ));
            cls.difference(&remove);
            if cls.ranges().is_empty() {
                return invalid();
            }
            Hir::class(hir::Class::Unicode(cls))
        }
        HirKind::Class(hir::Class::Bytes(mut cls)) => {
            let remove = hir::ClassBytes::new(Some(
                hir::ClassBytesRange::new(byte, byte),
            ));
            cls.difference(&remove);
            if cls.ranges().is_empty() {
                return invalid();
            }
            Hir::class(hir::Class::Bytes(cls))
        }
        HirKind::Anchor(x) => Hir::anchor(x),
        HirKind::WordBoundary(x) => Hir::word_boundary(x),
        HirKind::Repetition(mut x) => {
            x.hir = Box::new(strip_from_match_ascii(*x.hir, byte)?);
            Hir::repetition(x)
        }
        HirKind::Group(mut x) => {
            x.hir = Box::new(strip_from_match_ascii(*x.hir, byte)?);
            Hir::group(x)
        }
        HirKind::Concat(xs) => {
            let xs = xs.into_iter()
                .map(|e| strip_from_match_ascii(e, byte))
                .collect::<Result<Vec<Hir>, Error>>()?;
            Hir::concat(xs)
        }
        HirKind::Alternation(xs) => {
            let xs = xs.into_iter()
                .map(|e| strip_from_match_ascii(e, byte))
                .collect::<Result<Vec<Hir>, Error>>()?;
            Hir::alternation(xs)
        }
    })
}

#[cfg(test)]
mod tests {
    use regex_syntax::Parser;

    use error::Error;
    use super::{LineTerminator, strip_from_match};

    fn roundtrip(pattern: &str, byte: u8) -> String {
        roundtrip_line_term(pattern, LineTerminator::byte(byte)).unwrap()
    }

    fn roundtrip_crlf(pattern: &str) -> String {
        roundtrip_line_term(pattern, LineTerminator::crlf()).unwrap()
    }

    fn roundtrip_err(pattern: &str, byte: u8) -> Result<String, Error> {
        roundtrip_line_term(pattern, LineTerminator::byte(byte))
    }

    fn roundtrip_line_term(
        pattern: &str,
        line_term: LineTerminator,
    ) -> Result<String, Error> {
        let expr1 = Parser::new().parse(pattern).unwrap();
        let expr2 = strip_from_match(expr1, line_term)?;
        Ok(expr2.to_string())
    }

    #[test]
    fn various() {
        assert_eq!(roundtrip(r"[a\n]", b'\n'), "[a]");
        assert_eq!(roundtrip(r"[a\n]", b'a'), "[\n]");
        assert_eq!(roundtrip_crlf(r"[a\n]"), "[a]");
        assert_eq!(roundtrip_crlf(r"[a\r]"), "[a]");
        assert_eq!(roundtrip_crlf(r"[a\r\n]"), "[a]");

        assert_eq!(roundtrip(r"(?-u)\s", b'a'), r"(?-u:[\x09-\x0D\x20])");
        assert_eq!(roundtrip(r"(?-u)\s", b'\n'), r"(?-u:[\x09\x0B-\x0D\x20])");

        assert!(roundtrip_err(r"\n", b'\n').is_err());
        assert!(roundtrip_err(r"abc\n", b'\n').is_err());
        assert!(roundtrip_err(r"\nabc", b'\n').is_err());
        assert!(roundtrip_err(r"abc\nxyz", b'\n').is_err());
        assert!(roundtrip_err(r"\x0A", b'\n').is_err());
        assert!(roundtrip_err(r"\u000A", b'\n').is_err());
        assert!(roundtrip_err(r"\U0000000A", b'\n').is_err());
        assert!(roundtrip_err(r"\u{A}", b'\n').is_err());
        assert!(roundtrip_err("\n", b'\n').is_err());
    }
}
