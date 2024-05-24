# What Paths are Relevant for `tree-sitter` Use?

The `tree-sitter` cli can be affected by some per-user configuration.
What is this info, where is it stored, and how is behavior affected?

## Per-user Configuration

The `tree-sitter` cli's behavior can be affected by:

* Information stored within individual parser repositories
* Shared objects compiled from parser source

### Where Parser Repositories Live

If a JSON configuration file named `config.json` lives under one of
the following operating-system-dependent directories, its content can
affect various `tree-sitter` subcommand behavior (e.g. `parse`,
`highlight`, `dump-lanauges`, etc.):

* Linux - `~/.config/tree-sitter`
* Mac - `~/Library/Application Support/tree-sitter`
* Windows - `C:\Users\<username>\AppData\Roaming\tree-sitter`

Note that since tree-sitter 0.20.8, the directory in question can be
overridden via the `TREE_SITTER_DIR` environment variable.

A default `config.json` file will be generated in the appropriate
location via `tree-sitter`'s `init-config` subcommand and by default
it contains two keys:

* `parser-directories`
* `theme`

`parser-directories` specifies directories under which `tree-sitter`
will look for the root directories of the sources for individual
parsers.

Thus, for example, if one of the specified directories is the
equivalent of `~/src`, then `tree-sitter` will look for subdirectories
of `~/src` with names beginning with `tree-sitter-` and probe their
content for files like `package.json`.  The located content can affect
the cli's behavior.

`theme` affects the `highlight` subcommand's output.  See the official
docs mentioned below for more details.

### Where the Shared Objects Live

As the result of executing a variety of subcommands (e.g. `test`),
`tree-sitter` will compile `src/parser.c` and install the resulting
shared object under one of the following operating-system-dependent
directories:

* Linux - `~/.cache/tree-sitter`
* Mac - `~/Library/Caches/tree-sitter`
* Windows - `C:\Users\<username>\AppData\Local\tree-sitter`

Note that since tree-sitter 0.20.8, the directory in question can be
overridden via the `TREE_SITTER_LIBDIR` environment variable.

The `parse` subcommand is an example of a `tree-sitter` subcommand
that is affected by which shared objects can be found.

Sometimes it can be handy to manually remove a shared object and
"reinstall" a new one to be sure that the shared object in use by
`tree-sitter` is associated with the particular version of the grammar
you are working with.  In order to delete a shared object (or move it
out of the way), it's helpful to know where it lives :)

### Official Docs

At the time of this writing, the official docs describe per-user
configuration in the [Syntax Highlighting
section](https://tree-sitter.github.io/tree-sitter/syntax-highlighting#per-user-configuration) -
perhaps not the most intuitive location for the information, but at
least it exists somewhere :)

It's probably worth consulting the official docs because the
information located here may go stale at some point.

