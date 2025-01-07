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

Note that as of [this
PR](https://github.com/tree-sitter/tree-sitter/pull/4076):

> ... there's a RustRegex class similar to the JavaScript RegExp
> class, which takes in a single string that is a valid Rust regex,
> and this string will be processed as a pattern during parser
> generation.

However, this has not yet made it in to a release at the time of
writing.

