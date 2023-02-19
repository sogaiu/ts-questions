# What Regular Expression Features Are Supported?

According to
[#463](https://github.com/tree-sitter/tree-sitter/issues/463), regular
expression support in tree-sitter remains to be documented in detail.

Over tree-sitter's lifetime, features have been added incrementally
and this document tries to surface some of that.

A variety of "standard" features are supported, such as (but not
limited to):

* Sequences
* Alternation - `|`
* Quantifiers - `*`, `+`, `?`
* Grouping - some things between `(` and `)`
* Character Classes - some things between `[` and `]`
* Shorthands - `\d`, `\s`, `\w`

There is also some level of support for other constructs including
(but not only) [1]:

* Unicode property escapes
* Unicode character escapes
* Emoji [2]
* Character class boolean / binary operations [2] [3]

_N.B._ See [1] for a cautionary note on adoption of some of these
features.

Some things that do not seem to be currently supported include:

* Assertions such as `^` or `$`
* Case-insensitive matching - See [this
comment](https://github.com/tree-sitter/tree-sitter/issues/122#issuecomment-487054841)
for a possible work-around that doesn't involve an external scanner

To see some specifics, check out what follows the wall of footnotes
below :)

---

[1] It appears that some features are supported in a way unique to
tree-sitter, that is, they won't work as-is elsewhere in "ordinary"
JavaScript contexts (e.g. the character class boolean / binary
operations or not needing the "u" flag for certain constructs).

One approach is to try to get things working in a standardish
JavaScript context if possible (e.g. via the `node` REPL).

If a given feature doesn't work in an ordinary context, it might be
good to consider potential trade-offs from a maintenace and
development perspective.  (Sometimes it might be possible to
articulate things in a more verbose fashion just using the
"standard"-ish features.)

Maintenance might be impacted because at a future date, ECMAScript
might add support for similar features in a way that's not compatible
with (or subtly different from) how things are done in tree-sitter's
regular expression setup.

Development might be impacted because some features don't work in
common REPLs like `node` (making exploration, testing, and/or
investigation of issues potentially more time-consuming) and/or it
might cause confusion (which might lead to bugs or extra unexpected
time or resources being spent).

[2] It looks like there is support for versions of tree-sitter >=
0.20.5.  (Though there doesn't seem to be a 0.20.5 on the release
page, there is a 0.20.6 which was released in 2022-03.)

See the first post of [this
issue](https://github.com/tree-sitter/tree-sitter/pull/1660) from
2022-02-25 and [this
code](https://github.com/alex-pinkus/tree-sitter-swift/blob/a828c40ee9881e8705182c23a829b38a2199a00d/grammar.js#L1820-L1834).

[3] Character class boolean / binary operations don't seem to be part
of ordinary(?) JavaScript functionality.  See
[here](https://github.com/tree-sitter/tree-sitter/pull/1660) for why
they were included.  See discussion in [1] above regarding potential
issues if considering adoption.

---

## Features That Have Tests

The file
[`expand_token.rs`](https://github.com/tree-sitter/tree-sitter/blob/master/cli/src/generate/prepare_grammar/expand_tokens.rs)
has tests near its end for a variety of tree-sitter's regular
expression features.  AFAIU, these are tested for frequently so
perhaps they (or at least the examples and things that are "close" to
them) are less likely to break.

Listed below are some examples of the tested features adapted from the
tests' source code along with links to a relevant commit (often the
commit where something was introduced).

We tried to represent things using `RegExp()` rather than Rust's
literals as the former might be more useful when thinking about what
to express in `grammar.js`.  See the footnote [1] below for some
caveats though.

For a string argument to `RegExp()` with escaping, we also noted the
number of characters that were typed in (without delimiters) and how
many get "stored".  For example:

```
RegExp("\\w\\d\\s") - typed 9, stored 6
```

For more details on this, see footnote [2] below.

On to the features / examples...

* [Regex with sequences and alternatives](https://github.com/tree-sitter/tree-sitter/commit/ead6ca1738c52e8da4a2eb577d1c4c50b08593b4#diff-fdcbaf1f2c40fc964a70729c485133e9f7b5ada391f7df2e41e4c79e759a847bR184)
  * `RegExp("(a|b|c)d(e|f|g)?")`

* [Regex with repeats](https://github.com/tree-sitter/tree-sitter/commit/ead6ca1738c52e8da4a2eb577d1c4c50b08593b4#diff-fdcbaf1f2c40fc964a70729c485133e9f7b5ada391f7df2e41e4c79e759a847bR193)
  * `RegExp("a*")`

* [Regex with repeats in sequences](https://github.com/tree-sitter/tree-sitter/commit/ead6ca1738c52e8da4a2eb577d1c4c50b08593b4#diff-fdcbaf1f2c40fc964a70729c485133e9f7b5ada391f7df2e41e4c79e759a847bR200)
  * `RegExp("a((bc)+|(de)*)f")`

* [Regex with character ranges](https://github.com/tree-sitter/tree-sitter/commit/ead6ca1738c52e8da4a2eb577d1c4c50b08593b4#diff-fdcbaf1f2c40fc964a70729c485133e9f7b5ada391f7df2e41e4c79e759a847bR209)
  * `RegExp("[a-fA-F0-9]+")`

* [Regex with Perl character classes](https://github.com/tree-sitter/tree-sitter/commit/ead6ca1738c52e8da4a2eb577d1c4c50b08593b4#diff-fdcbaf1f2c40fc964a70729c485133e9f7b5ada391f7df2e41e4c79e759a847bR215)
  * `RegExp("\\w\\d\\s")` - typed 9, stored 6

* [Regex with an alternative including the empty string](https://github.com/tree-sitter/tree-sitter/commit/842421633c1161351ec0ba764be8927d09b15728#diff-7f1db9f2540cd0ef77297c4b775d971e59035ffe27759525e7bbf43d744394e2R388)
  * `RegExp("a(b|)+c")`

* [Allowing unrecognized escape sequences](https://github.com/tree-sitter/tree-sitter/commit/e2717a6ad14c6d1db056b55e89526b70eeb48a83#diff-28d5058b57b315002119f5fed2a52ebf644ff0ac86d2dcf663891dc9303448f1R622)

  * [Escaped forward slash (used in JS because '/' is the regex delimiter)](https://github.com/tree-sitter/tree-sitter/commit/e2717a6ad14c6d1db056b55e89526b70eeb48a83#diff-28d5058b57b315002119f5fed2a52ebf644ff0ac86d2dcf663891dc9303448f1R625)
    * `RegExp("\/")` - typed 2, stored 2
  * [Escaped quotes](https://github.com/tree-sitter/tree-sitter/commit/e2717a6ad14c6d1db056b55e89526b70eeb48a83#diff-28d5058b57b315002119f5fed2a52ebf644ff0ac86d2dcf663891dc9303448f1R627)
    * `RegExp("\\\"\\\'")` - typed 8, stored 4
  * [Quote preceded by a literal backslash](https://github.com/tree-sitter/tree-sitter/commit/e2717a6ad14c6d1db056b55e89526b70eeb48a83#diff-28d5058b57b315002119f5fed2a52ebf644ff0ac86d2dcf663891dc9303448f1R629)
    * `RegExp("[\\']+")` - typed 6, stored 5

* [Unicode property escapes](https://github.com/tree-sitter/tree-sitter/commit/5b630054c6999c134b3d2b2152b09424928efac4#diff-28d5058b57b315002119f5fed2a52ebf644ff0ac86d2dcf663891dc9303448f1R708) [#380](https://github.com/tree-sitter/tree-sitter/issues/380)
  * `RegExp("\\p{L}+\\P{L}+", "u")` - typed 14, stored 12
    * In `grammar.js` the `, "u"` flag portion may be ignored
  * `RegExp("\\p{White_Space}+\\P{White_Space}+[\\p{White_Space}]*", "u")`
    * In `grammar.js` the `, "u"` flag portion may be ignored.

* [Unicode property escapes in bracketed sets](https://github.com/tree-sitter/tree-sitter/commit/2f28a35e1b118e17ab2fb6236a24c7b557e3c8a9#diff-28d5058b57b315002119f5fed2a52ebf644ff0ac86d2dcf663891dc9303448f1R727) [#906](https://github.com/tree-sitter/tree-sitter/pull/906)
  * `RegExp("[\\p{L}\\p{Nd}]+", "u")` - typed 16, stored 14
    * In `grammar.js` the `, "u"` flag portion may be ignored

* [Unicode character escapes](https://github.com/tree-sitter/tree-sitter/commit/b46d51f224bdbfa8b4a1025b6e306ade7adef4d0#diff-28d5058b57b315002119f5fed2a52ebf644ff0ac86d2dcf663891dc9303448f1R720)
  * `RegExp("\u{00dc}", "u")` - typed 8, stored 8
    * In `grammar.js` the `, "u"` flag portion may be ignored
  * The tests also mention some examples which we didn't figure out how
    to express in a way that worked at a JavaScript REPL so we're
    skipping them for now.

* [Allowing un-escaped curly braces](https://github.com/tree-sitter/tree-sitter/commit/e2717a6ad14c6d1db056b55e89526b70eeb48a83#diff-28d5058b57b315002119f5fed2a52ebf644ff0ac86d2dcf663891dc9303448f1R639)
  * [Un-escaped curly braces](https://github.com/tree-sitter/tree-sitter/commit/e2717a6ad14c6d1db056b55e89526b70eeb48a83#diff-28d5058b57b315002119f5fed2a52ebf644ff0ac86d2dcf663891dc9303448f1R642)
  * [Already-escaped curly braces](https://github.com/tree-sitter/tree-sitter/commit/e2717a6ad14c6d1db056b55e89526b70eeb48a83#diff-28d5058b57b315002119f5fed2a52ebf644ff0ac86d2dcf663891dc9303448f1R644)
  * [Unicode codepoints](https://github.com/tree-sitter/tree-sitter/commit/e5584f82d3651d03de37164b0652a4e6390e682d#diff-28d5058b57b315002119f5fed2a52ebf644ff0ac86d2dcf663891dc9303448f1R654)
  * [Unicode codepoints (lowercase)](https://github.com/tree-sitter/tree-sitter/commit/4b0489e2f3c1136b206e93915ebedcc207d70969#diff-28d5058b57b315002119f5fed2a52ebf644ff0ac86d2dcf663891dc9303448f1R656)

* [Emojis](https://github.com/tree-sitter/tree-sitter/pull/1660/commits/8fadf186553998ae8992b1038e6cc72ef16353fc#diff-28d5058b57b315002119f5fed2a52ebf644ff0ac86d2dcf663891dc9303448f1R808)
  * `RegExp("\\p{Emoji}+", "u")` - typed 11, stored 10
    * In `grammar.js` the `, "u"` flag portion may be ignored
    * Note the possibly unexpected result that `#`, `*`, `0`, ..., `9`
      are all counted as "Emoji"" -- see
      [here](https://github.com/tree-sitter/tree-sitter/pull/1660#issuecomment-1053647855)
      for the start of a discussion on this point

* [Binary operations](https://github.com/tree-sitter/tree-sitter/pull/1660/commits/8fadf186553998ae8992b1038e6cc72ef16353fc#diff-28d5058b57b315002119f5fed2a52ebf644ff0ac86d2dcf663891dc9303448f1R821-R880)

  These all seem to have been [added to support
  Emoji](https://github.com/tree-sitter/tree-sitter/pull/1660) --
  specifically to exclude `#`, `*`, `0`, ..., `9` (as they get
  considered "Emoji" -- see above for link.).  We don't think they are
  supported by most flavors of JavaScript -- but that's a guess.  They
  don't seem to work at a `node` REPL.

  It's unclear to us whether there are potential future compatibility
  issues being made more likely by including these in their current
  form.  Imagine something like this gets added to ECMAScript in the
  future -- will the ones in tree-sitter currently gracefully work
  with what gets added?  There doesn't seem to be an obvious answer.
  For this concern, we're not intending to use them at this stage.  May
  be it's worth it for some cases though.

  For the above reasons we've not provided examples here, but there are
  links to the commit that added them and one can see examples there.

  * [Intersection](https://github.com/tree-sitter/tree-sitter/pull/1660/commits/8fadf186553998ae8992b1038e6cc72ef16353fc#diff-28d5058b57b315002119f5fed2a52ebf644ff0ac86d2dcf663891dc9303448f1R821)
  * [Difference](https://github.com/tree-sitter/tree-sitter/pull/1660/commits/8fadf186553998ae8992b1038e6cc72ef16353fc#diff-28d5058b57b315002119f5fed2a52ebf644ff0ac86d2dcf663891dc9303448f1R834)
  * [Symmetric difference](https://github.com/tree-sitter/tree-sitter/pull/1660/commits/8fadf186553998ae8992b1038e6cc72ef16353fc#diff-28d5058b57b315002119f5fed2a52ebf644ff0ac86d2dcf663891dc9303448f1R847)
  * [Nested set operations](https://github.com/tree-sitter/tree-sitter/pull/1660/commits/8fadf186553998ae8992b1038e6cc72ef16353fc#diff-28d5058b57b315002119f5fed2a52ebf644ff0ac86d2dcf663891dc9303448f1R860)

---

[1] Note that the `RegExp("...")` instances are what one might type in
while editing normal JavaScript in an editor or at a JavaScript REPL.
(We tried things out at a `node` REPL but it's possible there are
errors.)

However for use with the `tree-sitter` cli, the precise expression
within `grammar.js` might differ from what one might expect.

For example, it seems that not specifying "flags" such as "u" works in
places it would not if trying to achieve something similar in `node`.
[Here](https://github.com/alex-pinkus/tree-sitter-swift/blob/0fe0de56b528cbf24a654c734ca181b48be3831d/grammar.js#L76-L80)
is an example.  Perhaps the flag portion is just ignored if provided.

[2] For example if using `node`:

```
> r = RegExp("[\\']+")       // typed string has length 6 (no delims)
/[\']+/                      // representation has length 5 (no delims)
> r.source
"[\\']+"                     // might look like 6, but...
> r.source.length            // length of `.source` is 5
5
```

A more complex example:

```
> r = RegExp("\\\"\\\'")     // typed string has length 8
/\"\'/                       // representation has length 4
> r.source
`\\"\\'`                     // might look like 6, but...
> r.source.length            // length of `.source` is 4
4
```

One more example:

```
> r = RegExp("\/")           // typed string has length 2
/\//                         // representation has length 2
> r.source
'\\/'                        // might look like 3, but...
> r.source.length            // length of `.source` is 2
2
```

---

## Additional Items Not Demonstrated

The following items were not demonstrated earlier.  We didn't
understand some of them (e.g. "Separators"), some of them we didn't
come up with a concise way to demo, and others didn't seem that
specifically related to particular regular expression features per se.

Below are links to the commit that introduced the aforementioned
items, but note that it's possible things might have changed since
that time.

* [Longest match rule](https://github.com/tree-sitter/tree-sitter/commit/842421633c1161351ec0ba764be8927d09b15728#diff-7f1db9f2540cd0ef77297c4b775d971e59035ffe27759525e7bbf43d744394e2R370)
* [Separators](https://github.com/tree-sitter/tree-sitter/commit/842421633c1161351ec0ba764be8927d09b15728#diff-7f1db9f2540cd0ef77297c4b775d971e59035ffe27759525e7bbf43d744394e2R399)
* [Shorter tokens with higher precedence](https://github.com/tree-sitter/tree-sitter/commit/479400e5d3e7fdc1395868c0f19fe6415cb68bda#diff-7f1db9f2540cd0ef77297c4b775d971e59035ffe27759525e7bbf43d744394e2R507)
* [Immediate tokens with higher precedence](https://github.com/tree-sitter/tree-sitter/commit/cc0fbc0d9306a838d10a7b258a58fa7f76c55cc3#diff-7f1db9f2540cd0ef77297c4b775d971e59035ffe27759525e7bbf43d744394e2R538)
* [Nested groups](https://github.com/tree-sitter/tree-sitter/commit/522021b107c00bbd146dbc0f813d16e3bce8e550#diff-28d5058b57b315002119f5fed2a52ebf644ff0ac86d2dcf663891dc9303448f1R622)

## Reference Links

### Closed
* 2015-11-07 [#5 \d (for example) in regexps is not escaped in the C parser](https://github.com/tree-sitter/tree-sitter/issues/5)
* 2017-06-25 [#95 Make it easy to define identifiers that allow unicode character](https://github.com/tree-sitter/tree-sitter/issues/95)
* 2017-12-13 [#115 Update regex parser](https://github.com/tree-sitter/tree-sitter/issues/115) - `\a` misfeature(?) removed
* 2018-01-04 [#122 Fortran grammar for tree-sitter](https://github.com/tree-sitter/tree-sitter/issues/122) - case-insensitive regex not supported
* 2018-10-29 [#214 Regex: hex (\xFF) and unicode (\uFFFF) escape sequences support](https://github.com/tree-sitter/tree-sitter/pull/214)
* 2019-02-24 [#286 Codepoint support in regular expressions](https://github.com/tree-sitter/tree-sitter/issues/286)
* 2019-07-08 [#380 CURLY_BRACE_REGEX mangles regex properties](https://github.com/tree-sitter/tree-sitter/issues/380)
* 2020-01-06 [#517 Conflicts in RegExp](https://github.com/tree-sitter/tree-sitter/issues/517)
* 2020-12-13 [#848 Fields of NewRegex](https://github.com/tree-sitter/tree-sitter/issues/848)
* 2022-01-01 [#1564 Ignore case regexp modifier ignored in grammar](https://github.com/tree-sitter/tree-sitter/issues/1564) - not really resolved though

### Merged
* 2019-04-10 [#319 Allow hex characters in unicode code points](https://github.com/tree-sitter/tree-sitter/pull/319)
* 2021-01-30 [#906 Handle simple unicode property escapes in regexes](https://github.com/tree-sitter/tree-sitter/pull/906) - closes #95 #380

### Open
* 2019-01-05 [#261 Support case-insensitive regex flag](https://github.com/tree-sitter/tree-sitter/issues/261)
* 2019-10-16 [#463 Document supported Javascript Regexp capabilities](https://github.com/tree-sitter/tree-sitter/issues/463)
* 2020-05-17 [#621 Panic when a regex contains an invalid unicode code point](https://github.com/tree-sitter/tree-sitter/issues/621) - #906 may have addressed (partially?)
* 2021-06-12 [#1167 Parser hang with null character in grammar](https://github.com/tree-sitter/tree-sitter/issues/1167)

### Discussions
* 2021-07-10 [#1252 Regex lookahead requires external scanner](https://github.com/tree-sitter/tree-sitter/discussions/1252)
* 2021-08-18 [#1344 New Tree Sitter Parser for Emacs Lisp](https://github.com/tree-sitter/tree-sitter/discussions/1344) - has tips and info about nul / zero byte support
* 2021-11-12 [#1480 Match anything between '#{' and '#}'](https://github.com/tree-sitter/tree-sitter/discussions/1480) - external scanner may be required, but another interesting idea is also presented
* 2022-01-21 [#1610 Identifying a "special" comment](https://github.com/tree-sitter/tree-sitter/discussions/1610)
* 2022-07-26 [#1815 new RegExp vs regex literal](https://github.com/tree-sitter/tree-sitter/discussions/1815)

### Quotes and Comments of Interest

[comment@#122](https://github.com/tree-sitter/tree-sitter/issues/122#issuecomment-487054841) - case-insensitive regex tip

> In my parser I use an improved version of function:

```
function toCaseInsensitive(a) {
  var ca = a.charCodeAt(0);
  if (ca>=97 && ca<=122) return `[${a}${a.toUpperCase()}]`;
  if (ca>=65 && ca<= 90) return `[${a.toLowerCase()}${a}]`;
  return a;
}

function caseInsensitive (keyword) {
  return new RegExp(keyword
    .split('')
    .map(toCaseInsensitive)
    .join('')
  )
}
```

> so I can use it with groups, like:

```
    procedure_definition: $ => seq(
      caseInsensitive("proc(e(d(u(r(e)?)?)?)?)?"),
      $.identifier,
      $.parameter_list,
      $._endline,
      repeat($.local_list),
      repeat($._statementProc)
    ),
```

[comment@#380](https://github.com/tree-sitter/tree-sitter/issues/380#issuecomment-509075172) (rest of discussion worth viewing)

> The idea behind the escaping is to match the behavior of JavaScript regexes. We want that behavior because the main grammar language is a JavaScript DSL.

### Regex-related?
* 2018-02-11 [#130 Expressing permutations](https://github.com/tree-sitter/tree-sitter/issues/130)
* 2018-03-09 [#139 Sublime Syntax compatibility](https://github.com/tree-sitter/tree-sitter/issues/139)
* 2021-06-09 [#1151 Missing nodes for tokens matched by patterns (as of tree-sitter 0.19)](https://github.com/tree-sitter/tree-sitter/issues/1151)

### From Older `tree-sitter-cli` Repository

* [#53 When will Regex assertions like $ will be supported?](https://github.com/tree-sitter/tree-sitter-cli/issues/53)
