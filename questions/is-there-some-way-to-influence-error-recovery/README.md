# Is There Some Way to Influence Error Recovery?

One of tree-sitter's notable features is its ability to "recover from
errors".  Anecdotal evidence suggests that this works well in many
cases.

Unfortunately, according to the tree-sitter creator, for the other
cases, [there does not appear to be much / anything one can do at the
moment](https://github.com/tree-sitter/tree-sitter/issues/1870#issuecomment-1248659929):

> Yeah, there is intentionally not much that you as a grammar author
> can do to manipulate the error recovery.

though he has mentioned that:

> I do think there is a clear path to fixing these things within
> Tree-sitter, and I do plan to work on this eventually, but it'll
> take some significant focused time, so it may be a
> while. [...elided...] I wish I had more time to fix this right now.

## Discussion

[One of the explanations of
error-recovery](https://github.com/tree-sitter/tree-sitter/issues/224#issuecomment-436731626)
given by the tree-sitter creator is:

> The basic idea is that the parser accepts any string. If the string
> does not match the grammar, the parser corrects it to match the
> grammar. Currently, there are two types of corrections:

> 1. Skip some number of tokens or subtrees
> 2. Insert one missing token

> Obviously, for a given syntax error, there are multiple combinations
> of corrections that would work. The parser handles this decision
> similarly to how ambiguities are handled by the classic GLR
> algorithm: the parse stack forks into multiple branches, and tries a
> different possibility on each branch.

> We maintain two quantities associated with each branch of the parse stack:

> * error_cost - an integer measure of the number of subtrees skipped,
>   the total size of the subtrees skipped, and the number of missing
>   tokens inserted.

> * node_count - the number of valid syntax tree nodes that have been
>   added, since the last error.

> There is some heuristic logic for deciding when to discard branches
> of the parse stack based on their error cost and their node
> count. When the node count is small, it means that we've just
> recently encountered an error, so we want to allow a fairly large
> number of different branches to "compete", to see which one will
> turn out the best. When the node count is large, it means we have
> progressed far past the error, so we should allow very few different
> branches (eventually just one), in order to restore good parsing
> performance.

At one point, he gave [a sketch of an approach to providing some
"customization"](https://github.com/tree-sitter/tree-sitter/issues/1631#issuecomment-1028167981):

> Yeah, I'd still like to add support for generating error messages in
> Tree-sitter. I think it would "fit" in fine to the current library;
> it'd probably be a function that takes an ERROR node and returns
> some structured information about the location where the error was
> first detected, and which state the parser was in when the error was
> detected. From there, you could call another function to iterate
> over all of the valid symbols in that parse state.

## References

* [#26 Overhaul error
  recovery](https://github.com/tree-sitter/tree-sitter/pull/26)
* [#84 Avoid hangs during error
  recovery](https://github.com/tree-sitter/tree-sitter/pull/84)
* [#98 Tokens that match the empty string can result in infinite loops
  during error
  recovery](https://github.com/tree-sitter/tree-sitter/issues/98)
* [#101 Use a simpler approach to error
  recovery](https://github.com/tree-sitter/tree-sitter/pull/101)
* [#119 Add the ability to recover from errors by inserting missing
  tokens](https://github.com/tree-sitter/tree-sitter/pull/119)
* [#139 Sublime Syntax
  compatibility](https://github.com/tree-sitter/tree-sitter/issues/139)
* [#155 Fix some error recovery
  problems](https://github.com/tree-sitter/tree-sitter/pull/155) -
  explanation of some details including pausing and selection of stack
  to process
* [#168 Don't reuse nodes within
  ambiguities](https://github.com/tree-sitter/tree-sitter/pull/168)
* [#224 Error recovery
  strategy](https://github.com/tree-sitter/tree-sitter/issues/224)
* [#255 Helpful parser error
  messages](https://github.com/tree-sitter/tree-sitter/issues/255)
* [#288 parser in the infinite
  loop](https://github.com/tree-sitter/tree-sitter/issues/288)
* [#568 Unsatisfactory error
  recovery?](https://github.com/tree-sitter/tree-sitter/issues/1870)
* [#921 Generate "incomplete" nodes in the presence of syntax
  errors?](https://github.com/tree-sitter/tree-sitter/issues/923)
* [#1205 Is there any way to give hints to the error recovery
  process?](https://github.com/tree-sitter/tree-sitter/discussions/1205)
* [#1259 tree-sitter calls external scanner with all symbols marked
  valid](https://github.com/tree-sitter/tree-sitter/issues/1259)
* [#1617 Error Recovery at end of file stuck in infinite
  loop](https://github.com/tree-sitter/tree-sitter/issues/1617)
* [#1631 Unable to use tree sitter as parser for
  compiler](https://github.com/tree-sitter/tree-sitter/issues/1631) -
  [possible future
  extension](https://github.com/tree-sitter/tree-sitter/issues/1631#issuecomment-1028167981)
* [#1635 Add 'reserved word' construct: improve error recovery by
  avoiding treating reserved words as other
  tokens](https://github.com/tree-sitter/tree-sitter/pull/1635)
* [#1645 Incorrect incremental parse result found in Python test
  corpus](https://github.com/tree-sitter/tree-sitter/issues/1645)
* [#1783 Allow empty external tokens during error recovery, if they
  change the scanner's
  state](https://github.com/tree-sitter/tree-sitter/pull/1783)
* [#1870 How does one improve the error recovery of a
  grammar?](https://github.com/tree-sitter/tree-sitter/issues/1870)
* [#1993 Adding keyword extraction breaks MISSING
  node](https://github.com/tree-sitter/tree-sitter/issues/1993)
  
