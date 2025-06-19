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
                              tree_sitter/*.h
```

To produce `grammar.json`, the `tree-sitter` cli [invokes
a js runtime binary](https://github.com/tree-sitter/tree-sitter/blob/eaa10b279f208b47f65e77833d65763f072f3030/crates/generate/src/generate.rs#L359),
telling it to run
[`dsl.js`](https://github.com/tree-sitter/tree-sitter/blob/eaa10b279f208b47f65e77833d65763f072f3030/crates/generate/src/dsl.js).
In turn, `dsl.js` [`import`s
`grammar.js`](https://github.com/tree-sitter/tree-sitter/blob/eaa10b279f208b47f65e77833d65763f072f3030/crates/generate/src/dsl.js#L540)
which [produces output on standard
output](https://github.com/tree-sitter/tree-sitter/blob/eaa10b279f208b47f65e77833d65763f072f3030/crates/generate/src/dsl.js#L547-L550),
and this is [saved as
`grammar.json`](https://github.com/tree-sitter/tree-sitter/blob/eaa10b279f208b47f65e77833d65763f072f3030/crates/generate/src/generate.rs#L190).

To produce `parser.c` and `node-types.json`, the `tree-sitter` cli
[loads
`grammar.json`](https://github.com/tree-sitter/tree-sitter/blob/eaa10b279f208b47f65e77833d65763f072f3030/crates/generate/src/generate.rs#L180),
does [some
preparation](https://github.com/tree-sitter/tree-sitter/blob/eaa10b279f208b47f65e77833d65763f072f3030/crates/generate/src/generate.rs#L199-L207)
and [processes the
content](https://github.com/tree-sitter/tree-sitter/blob/eaa10b279f208b47f65e77833d65763f072f3030/crates/generate/src/generate.rs#L210-L218)
which is then used to [create the 2 aforementioned
files](https://github.com/tree-sitter/tree-sitter/blob/eaa10b279f208b47f65e77833d65763f072f3030/crates/generate/src/generate.rs#L220-L221)
[1].

Finally [`tree_sitter/*.h` are copied into
place](https://github.com/tree-sitter/tree-sitter/blob/eaa10b279f208b47f65e77833d65763f072f3030/crates/generate/src/generate.rs#L222-L224).

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
                tree_sitter/*.h
```

This has been possible since
[#260](https://github.com/tree-sitter/tree-sitter/pull/260) via [this
commit](https://github.com/tree-sitter/tree-sitter/commit/def5884b59495fbe3ff199f199eee58731f5398e).

