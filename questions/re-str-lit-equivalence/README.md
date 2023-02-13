# Can Regular Expression Literals and `RegExp` Be Used Interchangeably?

There are at least 2 common ways to articulate regular expressions in
JavaScript source code:

* Regular expression literals (e.g. `/[rR]elax/`)
* String literals used with `RegExp` (e.g. `RegExp("smile")`)

It seems that the `tree-sitter` cli can generate slightly different
results (`grammar.json` content) for what seem to be the same intent
(articulated in `grammar.js`).

## Discussion

A specific example of the aforementioned is the character class
containing a single forward slash.

Using regex literal syntax, this might be expressed as:

```js
/[\/]/
```

Note the use of a backslash to escape the forward slash.

Using string literal syntax with `RegExp`, one can express the same
intent as:

```js
RegExp("[/]")
```

In this latter case, the backslash character is not present as forward
slashes require no escaping inside a string literal used for a regular
expression like this one.

Assuming such constructs are used in `grammar.js` files,
`src/grammar.json` files generated via the `tree-sitter` cli's
`generate` subcommand can differ depending on the representations
chosen [1].  See the steps below for a demonstration.

---

[1] See [this](../generate-subcommand-files/README.md) for details on
files involved in `tree-sitter generate` invocations.

---

## Question: Does this difference matter?

In limited testing, the corresponding generated `src/parser.c` files
did NOT differ in a relevant way [1] (though as mentioned above
`src/grammar.json` files were different).

As NoahTheDuke's
[spelunking](https://github.com/sogaiu/tree-sitter-clojure/issues/40#issuecomment-1421040331)
[revealed](https://github.com/tree-sitter/tree-sitter/blob/5766b8a0a785ea34fceb479a94f7fe24c9daae2f/cli/src/generate/prepare_grammar/expand_tokens.rs#L63-L86),
there appears to be some preprocessing of regular expressions.

Perhaps that is sufficiently reliable and accurate?

---

[1] `src/parser.c` files differ in the demo below because the grammar
names differ, but that is not important for the current exploration.

---

## Why Care?

In our case, we think that comprehension and maintenance will likely
be significantly improved by using string literals and `RegExp`
(though it can be even better with the addition of a wrapper
function).  See
[here](https://github.com/sogaiu/tree-sitter-clojure/issues/40) for
details if interested.

FWIW, at the time of writing, we found around 20% of the [120 or so of
tree-sitter grammar repositories](../../ts-grammar-repositories.txt)
we checked made use of the `RegExp` construct, so it appears others
have found uses.  We suspect that [programmatic creation of regular
expression
objects](https://github.com/tree-sitter/tree-sitter/discussions/1815)
is likely to be the motivation in most of those cases.

(See the `count-repos` `Makefile` target for details.)

## Prerequisites for Demo

See the section of the corresponding name in the [repository
README](../../README.md).

## Demo Steps

* Ensure the current working directory is the repository root directory.
* `cd questions/re-str-lit-equivalence`
* Invoke `make show-inputs` to see the two `grammar.js` files
* Observe the two ways to express the same regular expression:

    ```js
      /[\/]/,            // <--- regex literal
    ```

    ```js
      RegExp("[/]"),     // <--- string literal
    ```
* Invoke `make` or `make demo`
* Observe output which should end like:

```diff
--- tree-sitter-relit/src/grammar.json	2023-02-13 01:52:10.763105901 +0000
+++ tree-sitter-strlit/src/grammar.json	2023-02-13 01:52:10.799106942 +0000
@@ -1,9 +1,9 @@
 {
-  "name": "relit",
+  "name": "strlit",
   "rules": {
     "source": {
       "type": "PATTERN",
-      "value": "[\\/]"
+      "value": "[/]"
     }
   },
   "extras": [
```
