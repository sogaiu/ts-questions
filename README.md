# Tree-sitter Questions

Some tree-sitter-related questions with discussions and some answers
and demos.

* [What Files Are Involved in `tree-sitter generate`?](questions/generate-subcommand-files/README.md)
* [Should Generated Parser Source Be Committed?](questions/should-parser-source-be-committed/README.md)
* [What ABI Version Should Be Used for `parser.c`?](questions/what-abi-level-should-be-used/README.md)
* [Are External Scanners Commonly Used?](questions/are-external-scanners-common/README.md)
* [Can Regular Expression Literals and `RegExp()` Be Used Interchangeably?](questions/re-str-lit-equivalence/README.md)
* [What Regular Expression Features Are Supported?](questions/what-regex-features-are-supported/README.md)
* [Which Version of Emscripten Should be Used for the Playground?](questions/which-version-of-emscripten-should-be-used-for-the-playground/README.md)
* [What Are Some Projects That Use Tree-sitter?](questions/what-are-some-projects-that-use-tree-sitter/README.md)
* [Is There A Changelog?](questions/is-there-a-changelog/README.md)

## Prerequisites for Demos

There are some demos in this repository which have prerequisites along
the following lines:

* \*nix-ish OS with Bourne-ish shell (only tested on a Linux box with bash though)
* git, diff, and other typical shell + dev clis
* make (used GNU's version 4.3 here, may be others will work too)
* tree-sitter 0.19.4 or up to
  [5766b8a0](https://github.com/tree-sitter/tree-sitter/commit/5766b8a0a785ea34fceb479a94f7fe24c9daae2f)

Assuming those things are in place, clone this repository:

```
git clone https://github.com/sogaiu/ts-questions
```

The demos that involve generating statistics across multple
repositories assume that parser / grammar repositories have been
fetched to live under a `repos` subdirectory of the repository root
directory.

The `repos` directory can be populated by running the following script
from the repository root directory:

```
sh ./script/fetch-repositories.sh
```

The list of repositories to fetch is determined via the file
[`ts-grammar-repositories.txt`](ts-grammar-repositories.txt) [1].

Repositories within `repos` can be updated by using the following
invocation in a manner analogous to the fetching one:

```
sh ./script/update-repositories.sh
```

This might be useful if one was interested in up-to-date statistics.

---

[1] Some care has been taken to cope with repository root directory
names that might collide (e.g. there is more than one
`tree-sitter-perl`).  The way this is done currently is to postfix the
"username" string from the repository URL.  It's possible this won't
always work, but it's been ok so far.

---

## Credits

* ahlinc
* amaanq
* damieng
* dannyfreeman
* NoahTheDuke

