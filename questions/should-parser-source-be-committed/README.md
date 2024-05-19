# Should Generated Parser Source Be Committed?

Since `parser.c` and friends [can be generated from `grammar.js` (or
`grammar.json`)](../generate-subcommand-files/README.md), wouldn't it
be ok to not commit them to one's grammar / parser repository?

## Discussion

On a few occasions
[1](https://github.com/tree-sitter/tree-sitter/issues/240#issuecomment-442184073)
[2](https://github.com/tree-sitter/tree-sitter-julia/pull/14#issuecomment-689143890)
[3](https://github.com/tree-sitter/tree-sitter/issues/447#issuecomment-533303827)
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

Of the checked repositories, it appears that around 93% have
`src/parser.c` committed.

ATM then, it appears most folks are doing so and numerous projects
that use tree-sitter assume this kind of setup.

Not doing so probably means that it's less likely for the grammar /
parser in question to get used as widely.

There appear to be what might be considered compromise options:

* https://github.com/alex-pinkus/tree-sitter-swift#where-is-your-parserc
  (related
  [issue](https://github.com/alex-pinkus/tree-sitter-swift/issues/149))
* https://github.com/DerekStride/tree-sitter-sql#installation (related
  [issue](https://github.com/DerekStride/tree-sitter-sql/issues/76))

It's probably worth noting that there are [security
implications](https://github.com/tree-sitter/tree-sitter/issues/1641)
for what most folks are doing.  (There might be [some related activity
attempting to address some of the
concerns](https://github.com/nvim-treesitter/nvim-treesitter/issues/4425#issuecomment-1452507887).)

## References

* [Store generated files as GH release artifacts instead of checking
  them into git
  repositories](https://github.com/tree-sitter/tree-sitter/issues/730)
* [Include generated files in
  repo](https://github.com/alex-pinkus/tree-sitter-swift/issues/149)
* [Where is your
  `parser.c`?](https://github.com/alex-pinkus/tree-sitter-swift#where-is-your-parserc)
* [Move `src/parser.c` to git
  LFS](https://github.com/tree-sitter/tree-sitter-c-sharp/issues/273)
* [Safe parser installation and central parser
  registry?](https://github.com/tree-sitter/tree-sitter/issues/1641)
