# How Can a Custom Playground Be Hosted?

Did you ever want to host your own custom version of a tree-sitter
playground?

May be you wanted to:

1. Demo the fruits of your labor to others more conveniently, or
2. Switch between similar grammars when developing an alternative, or
3. Provide a convenient way for others to investigate an issue, or

...for some other reason (^^;

## Discussion

The `tree-sitter` cli's `playground` subcommand starts a web server
that serves files that are "baked in" to the cli binary [1].  Although
this is convenient for local development, the arrangement does not
lend itself to easy hosting of those files nor to using multiple
grammars.

The following are some known approaches to ending up with a suitable
tree of files and directories for hosting:

1. Manually determine the relevant files by studying
   `cli/src/playground.rs` and related resources in the tree-sitter
   repository .  Then prepare the necessary files to live in an
   appropriate directory.

2. Copy-modify [the content which aheber prepared for
tree-sitter-sfapex](https://github.com/aheber/tree-sitter-sfapex/tree/main/docs)
or [the tree-sitter website's playground
content](https://tree-sitter.github.io/tree-sitter/playground).

On a side note, for each desired grammar, a corresponding `.wasm` file
is needed.  See the [official
instructions](https://github.com/tree-sitter/tree-sitter/tree/master/lib/binding_web#generate-wasm-language-files)
and/or [this
question](../which-version-of-emscripten-should-be-used-for-the-playground/README.md)
for more details.

## Misc

A link to [treeground](https://github.com/picomet/treeground) was
posted to the tree-sitter Discord server recently.  It looks
interesting and might be relevant, but the author of this document
doesn't know enough about it yet to say much more (^^;

## Footnotes

[1] The `tree-sitter playground` subcommand can also serve files from
a clone of the `tree-sitter` repository if the environment variable
`TREE_SITTER_BASE_DIR` is pointed at it.  See `cli/src/playground.rs`
in the tree-sitter repository for details.  Note that the grammar's
`.wasm` file is read from the grammar's repository directory.

