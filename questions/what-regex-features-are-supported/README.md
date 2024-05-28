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
[here](https://tree-sitter.github.io/tree-sitter/creating-parsers#the-grammar-dsl)
under the "Regex Limitations" bullet point.
