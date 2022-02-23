package main

import (
    "os"
    "fmt"
    "regexp"
    "github.com/microcosm-cc/bluemonday"
)

func main() {
    p := bluemonday.NewPolicy()

    p.AllowElements("p", "h3", "strong", "em", "u", "s", "span", "ol", "ul", "li", "blockquote", "pre", "br")

    p.AllowAttrs("class").Matching(regexp.MustCompile("^ql-align-(center|right|justify)$")).Globally()
    p.AllowAttrs("spellcheck").Matching(regexp.MustCompile("^false$")).OnElements("pre")
    p.AllowStyles("color", "background-color").Matching(regexp.MustCompile(`^rgb\([0-9]{1,3}, [0-9]{1,3}, [0-9]{1,3}\)$`)).Globally()

    html := p.SanitizeReader(os.Stdin)
    fmt.Print(html)
}
