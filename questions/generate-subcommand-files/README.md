# What Files Are Involved in `tree-sitter generate`?

The `tree-sitter` cli's `generate` subcommand is typically used to
create parser source code from a grammar's description (often
`grammar.js`).  Possibly the most well-known product is
`src/parser.c`.  What are the other involved files?

## Discussion

There are multiple files involved as well as multiple possible
sequences / flows.

### Basic

Possibly the most frequently used flow is associated with the invocation:

```
tree-sitter generate
```

Given `grammar.js` as an implicit input, a series of files is created:

```
grammar.js -> grammar.json -> parser.c
                              node-types.json
                              tree_sitter/api.h
```

To produce `grammar.json`, the `tree-sitter` cli [invokes
`node`](https://github.com/tree-sitter/tree-sitter/blob/5766b8a0a785ea34fceb479a94f7fe24c9daae2f/cli/src/generate/mod.rs#L171-L176),
telling it to run
[`dsl.js`](https://github.com/tree-sitter/tree-sitter/blob/5766b8a0a785ea34fceb479a94f7fe24c9daae2f/cli/src/generate/dsl.js).
In turn, `dsl.js` [`require`s
`grammar.js`](https://github.com/tree-sitter/tree-sitter/blob/5766b8a0a785ea34fceb479a94f7fe24c9daae2f/cli/src/generate/dsl.js#L417)
which [produces output on standard
output](https://github.com/tree-sitter/tree-sitter/blob/5766b8a0a785ea34fceb479a94f7fe24c9daae2f/cli/src/generate/dsl.js#L418),
and this is [saved as
`grammar.json`](https://github.com/tree-sitter/tree-sitter/blob/5766b8a0a785ea34fceb479a94f7fe24c9daae2f/cli/src/generate/mod.rs#L64).

To produce `parser.c` and `node-types.json`, the `tree-sitter` cli
[loads
`grammar.json`](https://github.com/tree-sitter/tree-sitter/blob/5766b8a0a785ea34fceb479a94f7fe24c9daae2f/cli/src/generate/mod.rs#L59),
does [some
preparation](https://github.com/tree-sitter/tree-sitter/blob/5766b8a0a785ea34fceb479a94f7fe24c9daae2f/cli/src/generate/mod.rs#L69-L71)
and [processes the
content](https://github.com/tree-sitter/tree-sitter/blob/5766b8a0a785ea34fceb479a94f7fe24c9daae2f/cli/src/generate/mod.rs#L75-L86)
which is then used to [create the 2 aforementioned
files](https://github.com/tree-sitter/tree-sitter/blob/5766b8a0a785ea34fceb479a94f7fe24c9daae2f/cli/src/generate/mod.rs#L88-L89)
[1].

Finally [`tree_sitter/api.h` is copied into
place](https://github.com/tree-sitter/tree-sitter/blob/5766b8a0a785ea34fceb479a94f7fe24c9daae2f/cli/src/generate/mod.rs#L90).

Usually `package.json` has already been created, but if it hasn't
been, it will also be created.

---

[1] IMHO, this is one of the most important things that the
`tree-sitter` cli does.

---

### Starting from `grammar.json`

Another possible flow is described by the invocation:

```
tree-sitter generate grammar.json
```

So it's possible to start from `grammar.json` instead of `grammar.js`.

```
grammar.json -> parser.c
                node-types.json
                tree_sitter/api.h
```

Again, usually `package.json` has already been created, but if it
hasn't been, it will also be created.

This has been possible since
[#260](https://github.com/tree-sitter/tree-sitter/pull/260) via [this
commit](https://github.com/tree-sitter/tree-sitter/commit/def5884b59495fbe3ff199f199eee58731f5398e).

Note that this means the following two things should be possible:

* Avoid using Node.js to produce `grammar.json`.  A different
  JavaScript runtime (that supports
  [`require`](https://github.com/tree-sitter/tree-sitter/issues/465#issuecomment-543840881)
  at least) can be used to execute `dsl.js`.  (This has been carried
  out by different parties on
  [multiple](https://github.com/tree-sitter/tree-sitter/issues/465#issuecomment-602107222)
  [occasions](https://github.com/tree-sitter/tree-sitter/issues/465#issuecomment-1371911897).)

* Generate `parser.c` and `node-types.json` starting from a
  `grammar.json` that was produced from something other than
  `grammar.js`.  For example, it might be possible to first start from
  a different grammar description by other parser generating programs
  to produce a suitable `grammar.json`, and then use the `.json` file
  as input to the `generate` invocation under discussion.  It appears
  there may be at least one party that has [done something along these
  lines](https://github.com/tree-sitter/tree-sitter/discussions/1413#discussioncomment-1414650).

### Bindings and `--no-bindings`

In addition to the previously mentioned files, the following Node.js
and Rust binding files / directories are typically created when the
`generate` subcommand is invoked (without tweaking its flags):

* `binding.gyp`
* `bindings/node/*`
* `bindings/rust/*`
* `Cargo.toml`

As mentioned previously, `package.json` will also be created if it
hasn't been.

Even if it exists already, it may be modified to add a `main` key for
the Node.js bindings -- if the modification occurs, the cli invocation
does indicate in output that `package.json` has been modified.

From version 0.19.4, it became possible to avoid having the
aforementioned processing via the [`--no-bindings`
flag](https://github.com/tree-sitter/tree-sitter/commit/8e894ff3f1898fcaa09ae125bbd5fde8467aea42).
