# How Can One Build the `tree-sitter` cli from Source?

The procedure has changed a number of times, but usually involves a C
compiler, the Rust toolchain, and Emscripten.

Unfortunately, recently, the use of Node.js became necessary for the
portion of the cli that involves `.wasm` (i.e. the `playground`
subcommand).  If you don't use the playground functionality of the
cli, building those bits might be skippable without harm.

Note that a possible upside to Emscripten being a prerequisite is that
when that is enabled (via its `emsdk_env.sh` script in *nixy
environments), it tends to make usable Node.js bits available as well.

In any case, for relatively up-to-date instructions, it's good to
consult the current "contributing" document, which also unfortunately,
has relocated itself on occasion.

At the time of writing, the contributing document is [this
one](https://github.com/tree-sitter/tree-sitter/blob/eaa10b279f208b47f65e77833d65763f072f3030/docs/src/6-contributing.md).

Previous to [this
commit](https://github.com/tree-sitter/tree-sitter/commit/043969ef18875a4b0330b7578fd2d21e7f826f63),
the contributing document lived
[here](https://github.com/tree-sitter/tree-sitter/blob/201b41cf11fb217a1f1ce03ea25b83e62b7b48cb/docs/section-6-contributing.md).
Knowing this information might be helpful if for some reason you need
to work with an older version of the cli.

The author isn't sure of exactly which version of the cli requires the
older documentation, but FWIW, the contributing document reached its
new home with the release of version `0.25.0`.  Note that the docs
(and hence the associated build instructions) are not always in sync.

