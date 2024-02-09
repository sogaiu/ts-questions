# Which Version of Emscripten Should be Used for the Playground?

The `tree-sitter` cli has a useful web-ui / playground feature
for trying out a language's grammar in an interactive manner.

Getting this to work can sometimes be tricky due to version
compatibility issues with Emscripten:

* [#571](https://github.com/tree-sitter/tree-sitter/issues/571)
* [#873](https://github.com/tree-sitter/tree-sitter/issues/873)
* [#1088](https://github.com/tree-sitter/tree-sitter/issues/1088)
* [#1098](https://github.com/tree-sitter/tree-sitter/issues/1098)
* [#1131](https://github.com/tree-sitter/tree-sitter/issues/1131)
* [#1560](https://github.com/tree-sitter/tree-sitter/issues/1560)
* [#1593](https://github.com/tree-sitter/tree-sitter/issues/1593)
* [#1652](https://github.com/tree-sitter/tree-sitter/issues/1652)
* [#1829](https://github.com/tree-sitter/tree-sitter/issues/1829)
* [#2005](https://github.com/tree-sitter/tree-sitter/discussions/2005)

## Discussion

When the stars are aligned appropriately [1], this can be made to
work via two subcommands:

```
tree-sitter build-wasm
```

```
tree-sitter playground
```

The first builds a `.wasm` file for the "current" grammar, while the
second arranges for a web server and browser to start, serving up the
playground for interaction.

Unfortunately, the version of Emscripten used in the `build-wasm` step
can matter a lot and this information is not clearly documented at the
time of this writing.

## Versions

Below is a collection of version pairs that we have found to be
compatible.  It's possible some other version combinations might work
too, but these are what we found to function appropriately.

```
tree-sitter  Emscripten
-----------  ----------
   0.19.3      2.0.11
   0.19.5      2.0.24
   0.20.7      2.0.24
  88fe1d00     3.1.29
   0.20.8      3.1.35
  c4871a26     3.1.35
   0.20.9      3.1.37
```

The following file histories may be of interest:

* https://github.com/tree-sitter/tree-sitter/blob/master/cli/loader/emscripten-version
* https://github.com/tree-sitter/tree-sitter/commits/master/cli/emscripten-version
* https://github.com/tree-sitter/tree-sitter/commits/master/emscripten-version

The first one is for what is currently used to track the version of
Emscripten that's supposed to work.

The second and third ones are for where the same information used to
live so if you happen to need to test an old enough version of
tree-sitter, they might be useful.

The information is not always correct but can provide a helpful
starting point in trying out various versions.

## Footnotes

[1] Assuming one has followed the [Emscripten Download and install
steps](https://emscripten.org/docs/getting_started/downloads.html),
usually an invocation from the emsdk source directory like:

```
source ./emsdk_env.sh
```

should be sufficient to make the activated version of Emscripten
available for use.
