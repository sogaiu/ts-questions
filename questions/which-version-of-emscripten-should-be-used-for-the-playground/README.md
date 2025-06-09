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
tree-sitter build --wasm      # in older versions, tree-sitter build-wasm
```

```
tree-sitter playground
```

The first builds a `.wasm` file for the "current" grammar, while the
second arranges for a web server and browser to start, serving up the
playground for interaction.

Unfortunately, the version of Emscripten used in the `build --wasm` step
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
   0.21.0      3.1.37
   0.22.0      3.1.37
   0.22.1      3.1.37
   0.22.2      3.1.37
   0.22.3      3.1.55
   0.22.4      3.1.55
   0.22.5      3.1.55
   0.22.6      3.1.55
  ce37b112     3.1.64
   0.23.0      3.1.64
   0.23.1      3.1.64
   0.23.2      3.1.64
   0.24.0      3.1.64
   0.24.1      3.1.64
   0.24.2      3.1.64
   0.24.3      3.1.64
   0.24.4      3.1.64
   0.24.5      3.1.64
   0.24.6      3.1.64
   0.24.7      3.1.64
  2c064039     3.1.74
  0e226561     4.0.1
   0.25.0      4.0.1
   0.25.1      4.0.1
   0.25.2      4.0.1
   0.25.3      4.0.1
  b1a9a827     4.0.4
   0.25.4      4.0.4
   0.25.5      4.0.4
   0.25.6      4.0.4
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

[1] There are instructions at [Emscripten Download and install
steps](https://emscripten.org/docs/getting_started/downloads.html)
for getting emsdk setup and ready for use.

However, the instructions specifically mention using `latest` for the
`install` and `activate` invocations, but for our purposes, it's
likely preferrable to use a specific version string.

For example, if the `tree-sitter` cli in use is version `0.25.4`, then
specify `4.0.4` (according to the table above) instead of `latest` in
both of the install and activate invocations.

For UNIXy environments:

```
./emsdk install 4.0.4
./emsdk activate 4.0.4
```

For Windows environments, for `cmd.exe`:

```
.\emsdk.bat install 4.0.4
.\emsdk.bat activate 4.0.4
```

... and for `powershell.exe`:

```
.\emsdk.ps1 install 4.0.4
.\emsdk.ps1 activate 4.0.4
```

To get an emsdk environment to be usable in the currently executing
shell (e.g. environment variables configured), there is an extra step
of running one of the `emsdk_env.*` scripts.  Unless the account's
shell configuration is altered, this will need to be done repeatedly
(e.g. if a new unrelated shell instance is started or on a future
login).  Also, the command to invoke depends on the shell in use.

UNIXy options include:

* `csh`: `source ./emsdk_env.csh`
* `fish`: `source ./emsdk_env.fish`
* `bash`, `ksh`, `zsh`: `source ./emsdk_env.sh`

Windows options include:

* `cmd.exe`: `.\emsdk_env.bat`
* `powershell.exe`: `.\emsdk_env.ps1`

