# Tree-sitter Questions

Some tree-sitter-related questions with discussions and some answers
and demos.

* [What Files Are Involved in `tree-sitter
  generate`?](questions/generate-subcommand-files/README.md)
* [Should Generated Parser Source Be
  Committed?](questions/should-parser-source-be-committed/README.md)
* [What ABI Version Should Be Used for
  `parser.c`?](questions/what-abi-level-should-be-used/README.md)
* [Are External Scanners Commonly
  Used?](questions/are-external-scanners-common/README.md)
* [What Regular Expression Features Are
  Supported?](questions/what-regex-features-are-supported/README.md)
* [Which Version of Emscripten Should be Used for the
  Playground?](questions/which-version-of-emscripten-should-be-used-for-the-playground/README.md)
* [What Are Some Projects That Use
  Tree-sitter?](questions/what-are-some-projects-that-use-tree-sitter/README.md)
* [How Can One Test for An Expected
  Error?](questions/how-to-test-for-an-expected-error/README.md)
* [Is There A Changelog?](questions/is-there-a-changelog/README.md)

## Prerequisites for Scripts

There are some scripts in this repository which have prerequisites along
the following lines:

* git
* [janet](https://github.com/janet-lang/janet)

Assuming those things are in place, clone this repository:

```
git clone https://github.com/sogaiu/ts-questions
```

The scripts that involve generating statistics across multple
repositories assume that parser / grammar repositories have been
fetched to live under a `repos` subdirectory of the repository root
directory.

The `repos` directory can be populated by running the following script
from this project's root directory:

```
janet ./script/fetch-repositories.janet
```

The list of repositories to fetch is determined via the file
[`ts-grammar-repositories.txt`](ts-grammar-repositories.txt).

Repositories within `repos` can be updated by using the following
invocation in a manner analogous to the fetching one:

```
janet ./script/update-repositories.janet
```

This might be useful if one was interested in up-to-date statistics.

---

## Credits

* ahelwer
* ahlinc
* amaanq
* clason and nvim-treesitter contributors
* damieng
* dannyfreeman
* NoahTheDuke

