# What Regular Expression Features Are Supported?

Since [tree-sitter
0.22.0](https://github.com/tree-sitter/tree-sitter/releases/tag/v0.22.0),
thanks to CAD97's [PR
#2838](https://github.com/tree-sitter/tree-sitter/pull/2838):

> Regexes are now always interpreted by Tree-sitter using Rust
> flavored regex syntax. The main impact is that { now need to be
> escaped outside of []. If this occurs in your grammar, Tree-sitter
> will error, indicating the regex which needs to be edited.

The official docs mention some limitations
[here](https://tree-sitter.github.io/tree-sitter/creating-parsers/2-the-grammar-dsl.html)
under the "Regex Limitations" bullet point.

Note that:

> ... DSL accepts a valid JS regex, however, we process it internally
> as a Rust regex and then expand it into NFA state(s) to be later
> processed by the lex table builder. The problem is, even though we
> internally use Rust's regex patterns, there's no way for us to
> actually pass in a Rust regex when writing a grammar.

via: https://github.com/tree-sitter/tree-sitter/pull/4076

At the time of this writing, the above PR has not yet been merged, but
once it is, more of the underlying Rust regex functionality should
become available as:

> ... there's a RustRegex class similar to the JavaScript RegExp
> class, which takes in a single string that is a valid Rust regex,
> and this string will be processed as a pattern during parser
> generation.

