use regex_syntax::ast::{self, Ast};
use regex_syntax::ast::parse::Parser;

/// The results of analyzing AST of a regular expression (e.g., for supporting
/// smart case).
#[derive(Clone, Debug)]
pub struct AstAnalysis {
    /// True if and only if a literal uppercase character occurs in the regex.
    any_uppercase: bool,
    /// True if and only if the regex contains any literal at all.
    any_literal: bool,
    /// True if and only if the regex consists entirely of a literal and no
    /// other special regex characters.
    all_verbatim_literal: bool,
}

impl AstAnalysis {
    /// Returns a `AstAnalysis` value by doing analysis on the AST of `pattern`.
    ///
    /// If `pattern` is not a valid regular expression, then `None` is
    /// returned.
    #[allow(dead_code)]
    pub fn from_pattern(pattern: &str) -> Option<AstAnalysis> {
        Parser::new()
            .parse(pattern)
            .map(|ast| AstAnalysis::from_ast(&ast))
            .ok()
    }

    /// Perform an AST analysis given the AST.
    pub fn from_ast(ast: &Ast) -> AstAnalysis {
        let mut analysis = AstAnalysis::new();
        analysis.from_ast_impl(ast);
        analysis
    }

    /// Returns true if and only if a literal uppercase character occurs in
    /// the pattern.
    ///
    /// For example, a pattern like `\pL` contains no uppercase literals,
    /// even though `L` is uppercase and the `\pL` class contains uppercase
    /// characters.
    pub fn any_uppercase(&self) -> bool {
        self.any_uppercase
    }

    /// Returns true if and only if the regex contains any literal at all.
    ///
    /// For example, a pattern like `\pL` reports `false`, but a pattern like
    /// `\pLfoo` reports `true`.
    pub fn any_literal(&self) -> bool {
        self.any_literal
    }

    /// Returns true if and only if the entire pattern is a verbatim literal
    /// with no special meta characters.
    ///
    /// When this is true, then the pattern satisfies the following law:
    /// `escape(pattern) == pattern`. Notable examples where this returns
    /// `false` include patterns like `a\u0061` even though `\u0061` is just
    /// a literal `a`.
    ///
    /// The purpose of this flag is to determine whether the patterns can be
    /// given to non-regex substring search algorithms as-is.
    #[allow(dead_code)]
    pub fn all_verbatim_literal(&self) -> bool {
        self.all_verbatim_literal
    }

    /// Creates a new `AstAnalysis` value with an initial configuration.
    fn new() -> AstAnalysis {
        AstAnalysis {
            any_uppercase: false,
            any_literal: false,
            all_verbatim_literal: true,
        }
    }

    fn from_ast_impl(&mut self, ast: &Ast) {
        if self.done() {
            return;
        }
        match *ast {
            Ast::Empty(_) => {}
            Ast::Flags(_)
            | Ast::Dot(_)
            | Ast::Assertion(_)
            | Ast::Class(ast::Class::Unicode(_))
            | Ast::Class(ast::Class::Perl(_)) => {
                self.all_verbatim_literal = false;
            }
            Ast::Literal(ref x) => {
                self.from_ast_literal(x);
            }
            Ast::Class(ast::Class::Bracketed(ref x)) => {
                self.all_verbatim_literal = false;
                self.from_ast_class_set(&x.kind);
            }
            Ast::Repetition(ref x) => {
                self.all_verbatim_literal = false;
                self.from_ast_impl(&x.ast);
            }
            Ast::Group(ref x) => {
                self.all_verbatim_literal = false;
                self.from_ast_impl(&x.ast);
            }
            Ast::Alternation(ref alt) => {
                self.all_verbatim_literal = false;
                for x in &alt.asts {
                    self.from_ast_impl(x);
                }
            }
            Ast::Concat(ref alt) => {
                for x in &alt.asts {
                    self.from_ast_impl(x);
                }
            }
        }
    }

    fn from_ast_class_set(&mut self, ast: &ast::ClassSet) {
        if self.done() {
            return;
        }
        match *ast {
            ast::ClassSet::Item(ref item) => {
                self.from_ast_class_set_item(item);
            }
            ast::ClassSet::BinaryOp(ref x) => {
                self.from_ast_class_set(&x.lhs);
                self.from_ast_class_set(&x.rhs);
            }
        }
    }

    fn from_ast_class_set_item(&mut self, ast: &ast::ClassSetItem) {
        if self.done() {
            return;
        }
        match *ast {
            ast::ClassSetItem::Empty(_)
            | ast::ClassSetItem::Ascii(_)
            | ast::ClassSetItem::Unicode(_)
            | ast::ClassSetItem::Perl(_) => {}
            ast::ClassSetItem::Literal(ref x) => {
                self.from_ast_literal(x);
            }
            ast::ClassSetItem::Range(ref x) => {
                self.from_ast_literal(&x.start);
                self.from_ast_literal(&x.end);
            }
            ast::ClassSetItem::Bracketed(ref x) => {
                self.from_ast_class_set(&x.kind);
            }
            ast::ClassSetItem::Union(ref union) => {
                for x in &union.items {
                    self.from_ast_class_set_item(x);
                }
            }
        }
    }

    fn from_ast_literal(&mut self, ast: &ast::Literal) {
        if ast.kind != ast::LiteralKind::Verbatim {
            self.all_verbatim_literal = false;
        }
        self.any_literal = true;
        self.any_uppercase = self.any_uppercase || ast.c.is_uppercase();
    }

    /// Returns true if and only if the attributes can never change no matter
    /// what other AST it might see.
    fn done(&self) -> bool {
        self.any_uppercase && self.any_literal && !self.all_verbatim_literal
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn analysis(pattern: &str) -> AstAnalysis {
        AstAnalysis::from_pattern(pattern).unwrap()
    }

    #[test]
    fn various() {
        let x = analysis("");
        assert!(!x.any_uppercase);
        assert!(!x.any_literal);
        assert!(x.all_verbatim_literal);

        let x = analysis("foo");
        assert!(!x.any_uppercase);
        assert!(x.any_literal);
        assert!(x.all_verbatim_literal);

        let x = analysis("Foo");
        assert!(x.any_uppercase);
        assert!(x.any_literal);
        assert!(x.all_verbatim_literal);

        let x = analysis("foO");
        assert!(x.any_uppercase);
        assert!(x.any_literal);
        assert!(x.all_verbatim_literal);

        let x = analysis(r"foo\\");
        assert!(!x.any_uppercase);
        assert!(x.any_literal);
        assert!(!x.all_verbatim_literal);

        let x = analysis(r"foo\w");
        assert!(!x.any_uppercase);
        assert!(x.any_literal);
        assert!(!x.all_verbatim_literal);

        let x = analysis(r"foo\S");
        assert!(!x.any_uppercase);
        assert!(x.any_literal);
        assert!(!x.all_verbatim_literal);

        let x = analysis(r"foo\p{Ll}");
        assert!(!x.any_uppercase);
        assert!(x.any_literal);
        assert!(!x.all_verbatim_literal);

        let x = analysis(r"foo[a-z]");
        assert!(!x.any_uppercase);
        assert!(x.any_literal);
        assert!(!x.all_verbatim_literal);

        let x = analysis(r"foo[A-Z]");
        assert!(x.any_uppercase);
        assert!(x.any_literal);
        assert!(!x.all_verbatim_literal);

        let x = analysis(r"foo[\S\t]");
        assert!(!x.any_uppercase);
        assert!(x.any_literal);
        assert!(!x.all_verbatim_literal);

        let x = analysis(r"foo\\S");
        assert!(x.any_uppercase);
        assert!(x.any_literal);
        assert!(!x.all_verbatim_literal);

        let x = analysis(r"\p{Ll}");
        assert!(!x.any_uppercase);
        assert!(!x.any_literal);
        assert!(!x.all_verbatim_literal);

        let x = analysis(r"aBc\w");
        assert!(x.any_uppercase);
        assert!(x.any_literal);
        assert!(!x.all_verbatim_literal);

        let x = analysis(r"a\u0061");
        assert!(!x.any_uppercase);
        assert!(x.any_literal);
        assert!(!x.all_verbatim_literal);
    }
}
