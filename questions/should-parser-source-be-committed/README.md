# Should Generated Parser Source Be Committed?

Since `parser.c` and friends [can be generated from `grammar.js` (or
`grammar.json`)](../generate-subcommand-files/README.md), wouldn't it
be ok to not commit them to one's grammar / parser repository?

## Discussion

On at least [one
occasion](https://github.com/tree-sitter/tree-sitter/issues/447#issuecomment-533303827)
maxbrunsfeld has recommended including generated parse source.

Also, currently, various parties (e.g. nvim-treesitter,
tree-sitter-langs, Emacs 29+, Cursorless, difftastic, helix-editor,
semgrep, etc.) assume the inclusion of these files to varying degrees.

In late 2020, [maxbrunsfeld sketched out a draft
plan](https://github.com/tree-sitter/tree-sitter/issues/730#issuecomment-736018228)
to move away from doing this.  A few months later(?), a form of this
was added to the [Tree-sitter 1.0
Checklist](https://github.com/tree-sitter/tree-sitter/issues/930)
(search for "Mergeable Git Repos").

Of the checked repositories, it appears that about 90% have
`src/parser.c` committed.

ATM then, it appears most folks are doing so and numerous projects
that use tree-sitter assume this kind of setup.

Not doing so probably means that it's less likely for the grammar /
parser in question to get used as widely.

There appear to be what might be considered [compromise
options](https://github.com/alex-pinkus/tree-sitter-swift/issues/149)
too.

## Prerequisites for Demo

See the section of the corresponding name in the [repository
README](../../README.md).

## Demo Steps

* Ensure the current working directory is the repository root directory.
* `cd questions/should-parser-source-be-committed`
* Invoke `sh ./script/list-provides-parser-c.sh`
* Observe output that ends like:

```
Minimum number of repositories with parser.c: 244
Number of repositories: 268
```

## References

* [Store generated files as GH release artifacts instead of checking them into git repositories](https://github.com/tree-sitter/tree-sitter/issues/730)
* [Include generated files in repo](https://github.com/alex-pinkus/tree-sitter-swift/issues/149)
* [Where is your `parser.c`?](https://github.com/alex-pinkus/tree-sitter-swift#where-is-your-parserc)
* [Move `src/parser.c` to git LFS](https://github.com/tree-sitter/tree-sitter-c-sharp/issues/273)
