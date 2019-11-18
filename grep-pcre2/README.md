grep-pcre2
----------
The `grep-pcre2` crate provides an implementation of the `Matcher` trait from
the `grep-matcher` crate. This implementation permits PCRE2 to be used in the
`grep` crate for fast line oriented searching.

[![Linux build status](https://api.travis-ci.org/BurntSushi/ripgrep.svg)](https://travis-ci.org/BurntSushi/ripgrep)
[![Windows build status](https://ci.appveyor.com/api/projects/status/github/BurntSushi/ripgrep?svg=true)](https://ci.appveyor.com/project/BurntSushi/ripgrep)
[![](https://img.shields.io/crates/v/grep-pcre2.svg)](https://crates.io/crates/grep-pcre2)

Dual-licensed under MIT or the [UNLICENSE](http://unlicense.org).

### Documentation

[https://docs.rs/grep-pcre2](https://docs.rs/grep-pcre2)

**NOTE:** You probably don't want to use this crate directly. Instead, you
should prefer the facade defined in the
[`grep`](https://docs.rs/grep)
crate.

If you're looking to just use PCRE2 from Rust, then you probably want the
[`pcre2`](https://docs.rs/pcre2)
crate, which provide high level safe bindings to PCRE2.

### Usage

Add this to your `Cargo.toml`:

```toml
[dependencies]
grep-pcre2 = "0.1"
```

and this to your crate root:

```rust
extern crate grep_pcre2;
```
