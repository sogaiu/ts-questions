# How Can One Test for An Expected Error

Error node locations may vary across time but one might still want to
have a test to express that an error is expected.

This can be achieved using the [:error
attribute](https://tree-sitter.github.io/tree-sitter/creating-parsers#attributes)
feature of tree-sitter that was introduced in [version 0.22.0 of the
tree-sitter CLI
tool](https://github.com/tree-sitter/tree-sitter/releases/tag/v0.22.0).

Below is a sample test.

```
================================================================================
Invalid comment

:error
:language(xml)
================================================================================

<error>
<!-- invalid -- -->
</error>

--------------------------------------------------------------------------------
```

There are more examples
[here](https://github.com/tree-sitter-grammars/tree-sitter-xml/blob/648183d86f6f8ffb240ea11b4c6873f6f45d8b67/test/corpus/errors.txt).

## References

* [ahelwer's question](https://github.com/tree-sitter/tree-sitter/issues/3366)
* [Command: test -> Attributes](https://tree-sitter.github.io/tree-sitter/creating-parsers#attributes)
* [File with examples](https://github.com/tree-sitter-grammars/tree-sitter-xml/blob/648183d86f6f8ffb240ea11b4c6873f6f45d8b67/test/corpus/errors.txt)