# Are External Scanners Commonly Used?

Let's start with what an external scanner is.

To quote the official docs:

> Many languages have some tokens whose structure is impossible or
> inconvenient to describe with a regular expression...

> Tree-sitter allows you to handle these kinds of tokens using
> external scanners. An external scanner is a set of C functions that
> you, the grammar author, can write by hand in order to add custom
> logic for recognizing certain tokens.

How common is this need?

## Discussion

Note that C++ is also an option for implementing an external scanner.
IIUC, as long as one can produce an appropriate binary object to be
linked, perhaps other languages can be used to implement an external
scanner [1].  (We haven't seen an example of this, but we didn't go
looking either.)

As far as how common it is to have an external scanner, based on
searching locally fetched repositories, we found around 44% of the 308
or so we checked had `src/scanner.c` or `src/scanner.cc`.

If it's any consolation, if it turns out you need to implement an
external scanner, there are a fair number of examples to study :)

Although not all repositories have parser source (e.g. `src/parser.c`)
committed to their repositories, `scanner.(c|cc)` is not typically a
generated file, so it seems unlikely that of the repositories fetched,
the above search was undercounting by much.

---

[1] See [here and follow-up
comment](https://github.com/tree-sitter/tree-sitter/issues/930#issuecomment-986017729).

---

## Prerequisites for Demo

See the section of the corresponding name in the [repository
README](../../README.md).

## Demo Steps

* Ensure the current working directory is the repository root directory.
* `cd questions/are-external-scanners-common`
* Invoke `sh ./script/list-uses-scanner.sh`
* Observe output that ends like:

```
Minimum number of repositories with scanner.c: 105
Minimum number of repositories with scanner.cc: 29
Number of repositories: 308
```

Tip: the output above the summary lines at the end is split into two
via a single blank line.  Above the line are paths to `scanner.c`,
while below the line are paths to `scanner.cc`.

For example:

```
tree-sitter-toml.ikatyang/src/scanner.c
tree-sitter-typescript.tree-sitter/tsx/src/scanner.c
tree-sitter-typescript.tree-sitter/typescript/src/scanner.c
tree-sitter-unifieddiff.monaqa/src/scanner.c
tree-sitter-uxntal.amaanq/src/scanner.c
```

and:

```
tree-sitter-norg2.nvim-neorg/src/scanner.cc
tree-sitter-ocaml.tree-sitter/interface/src/scanner.cc
tree-sitter-ocaml.tree-sitter/ocaml/src/scanner.cc
tree-sitter-ocamllex.atom-ocaml/src/scanner.cc
tree-sitter-org.milisims/src/scanner.cc
```

Note that the path to a scanner source file is not always directly
rooted in the project repository like `src/scanner.*`, it might be one
level deeper.

## References

* [External scanner official docs](https://tree-sitter.github.io/tree-sitter/creating-parsers#external-scanners)
* [comment@#53 (old tree-sitter-cli repository)](https://github.com/tree-sitter/tree-sitter-cli/issues/53#issuecomment-452462914) - early info about external scanners
* [#219 Builtin support for white space sensitive languages](https://github.com/tree-sitter/tree-sitter/issues/219)
* [#281 Document external scanners](https://github.com/tree-sitter/tree-sitter/issues/281)
* [#1100 Runtime parsing variables](https://github.com/tree-sitter/tree-sitter/discussions/1100)
* [#1259 tree-sitter calls external scanner with all symbols marked valid](https://github.com/tree-sitter/tree-sitter/issues/1259)
* [#1627 External scanner in test](https://github.com/tree-sitter/tree-sitter/issues/1627)
