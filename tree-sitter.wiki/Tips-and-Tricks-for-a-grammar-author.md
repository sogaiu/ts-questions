This page will just be a dump of my thoughts and helpful pointers I have for anyone trying to get into that intermediate/advanced level of writing a grammar. I will update this as time goes on, but hopefully once we migrate our docs to a better tool I can integrate a cookbook/tutorial that has a bunch of levels that incorporate these ideas.


## Reducing state count:

There are many ways you can do this, but here's common tricks I utilize:

1. `tree-sitter generate --report-states-for-rule -`
This shows you all the rules and their possible # of states, the biggest ones *can* be but are not always an indicator of a poorly written rule.

To really see this in action, let's check out how I utilized this in tree-sitter-c. Check out v0.20.5, and run `tree-sitter generate --report-states-for-rule -`. You should get this:

```
ts g --report-states-for-rule -
for_statement                               	318
type_definition                             	295
binary_expression                           	215
conditional_expression                      	187
update_expression                           	180
...etc
```

So, to me binary expression does *not* stand out, because of all the combinations between operators creating states. Theses states are simple and shouldn't be thought of. What IS more concerning, is for_statement and type_definition. Here's what it looks like in 0.20.5:

```js
    for_statement: $ => seq(
      'for',
      '(',
      choice(
        field('initializer', $.declaration),
        seq(field('initializer', optional(choice($._expression, $.comma_expression))), ';'),
      ),
      field('condition', optional(choice($._expression, $.comma_expression))), ';',
      field('update', optional(choice($._expression, $.comma_expression))),
      ')',
      field('body', $._statement),
    ),   
```

This is relatively large, and can be refactored out. Refactoring is tricky and requires some creativity, so be sure to try out different combinations that make the most sense. Refactor, regenerate, check state counts, rinse and repeat.

What ended up being the best was creating a `_for_statement_body` which contains the bits inside a for statements parenthesis - the initializer, condition, and update:

```js
    for_statement: $ => seq(
      'for',
      '(',
      $._for_statement_body,
      ')',
      field('body', $._statement),
    ),
    _for_statement_body: $ => seq(
      choice(
        field('initializer', $.declaration),
        seq(field('initializer', optional(choice($._expression, $.comma_expression))), ';'),
      ),
      field('condition', optional(choice($._expression, $.comma_expression))),
      ';',
      field('update', optional(choice($._expression, $.comma_expression))),
    ),   
```

Note, some refactoring can *increase* state count, you will get a feel for it by just trying to extract different parts out

Let's regenerate and check state count. On 0.20.5, we're at 2243 for STATE_COUNT and 666 for LARGE_STATE_COUNT.

This can be checked with `cat src/parser.c | rg "#define.*STATE"` (rg is ripgrep, grep works too)

After that *simple* refactor, we're down to 2048/610. Incredible, right? This can be applied in any case where a bad rule may exist.

Let's look at type_definition now, in 0.20.5 it looks like this:

```js
    type_definition: $ => seq(
      optional('__extension__'),
      'typedef',
      repeat($.type_qualifier),
      field('type', $._type_specifier),
      repeat($.type_qualifier),
      commaSep1(field('declarator', $._type_declarator)),
      repeat($.attribute_specifier),
      ';',
    ),
```

There's way too many repeats and optionals in *one* rule, this definitely needs to be refactored. We don't want nodes refactored visible though, a user should just see a type_definition which contains all these items. Utilizing hidden rules (rules prepended with _) is key here.

So, let's move the section that sorta is the "type" and the section that is the declarators to their own nodes:

```js
    type_definition: $ => seq(
      optional('__extension__'),
      'typedef',
      $._type_definition_type,
      $._type_definition_declarators,
      repeat($.attribute_specifier),
      ';',
    ),
    _type_definition_type: $ => seq(repeat($.type_qualifier), field('type', $._type_specifier), repeat($.type_qualifier)),
    _type_definition_declarators: $ => commaSep1(field('declarator', $._type_declarator)),
```

Regenerate..and...

```
$ cat src/parser.c | rg "#define.*STATE"
#define STATE_COUNT 1825
#define LARGE_STATE_COUNT 510
```

Well, isn't that amazing? We're down 400 in state count, almost a 20% reduction, from just two simple refactors

Let's revisit `tree-sitter generate --report-states-for-rule -` now:

```
$ ts g --report-states-for-rule -
binary_expression                               165
conditional_expression                          137
update_expression                               130
field_expression                                127
...etc
```

Not only are for_statement and type_definition not the 2 largest states, but they're #7 and #10 respectively, which seems a lot better. In addition, states for everything else went down as a consequence! Binary expression being #1 makes sense, there's 18 operators to combine with two expressions. These are not large states by any means compared to what we had before.


External Scanner Building & Debugging

1. If you are stuck about what/where gets advanced during what phase/state, this macro hack is worthy of using. 

```c
static inline void advance(TSLexer *lexer) { lexer->advance(lexer, false); }

static inline void skip(TSLexer *lexer) { lexer->advance(lexer, true); }

#define advance(lexer) {\
	printf("advance %c, L%d\n", lexer->lookahead, __LINE__);\
	advance(lexer);\
}

#define skip(lexer) {\
	printf("skip %c, L%d\n", lexer->lookahead, __LINE__);\
	skip(lexer);\
}
```

Everytime skip or advance is called, you will get a debug print of what the lookahead is, and what *line* in the source code this occurred on. To me, that makes all the difference when a scanner can get complicated with multiple states.

2. When/how to use mark_end

`lexer->mark_end` can be a bit tricky for beginners trying to peek ahead several tokens. Let's make it easier

Consider the following scenario:

A test operator is not valid unless it follows zero-or-more-tokens of whitespace + a backslash, then a newline or a dollar sign. This is complex, so let's think about how to tokenize the test operator, how to peek ahead so many tokens, how to correctly construct the scenario I described, and how to return symbols correctly. The biggest challenge will be to get how things *should* parse from your head into code. I would try and write down or comment different scenarios meant to happen associated with the blocks that are relevant. 

We will consider a test operator to be "-a" to keep the code brief, but it applies for any n-token operator

Scenario I described:

```c
enum TokenType {
    TEST_OPERATOR
}

// boilerplate...

bool tree_sitter_lang_external_scanner_scan(void* payload, TSLexer *lexer, const bool *valid_symbols) {
  // first, actually check if a TEST_OPERATOR is valid, and if it is, advance it. for our case, we will consider -a to be a test operator
    if (valid_symbols[TEST_OPERATOR]) {
    if (lexer->lookahead == '-') {
      advance(lexer, false);
    } else {
      return false;
    }

    if (lexer->lookahead == 'a') {
      lexer->advance(lexer, false);
    } else {
      return false;
    }

    // now we do *not* want to consume any more characters and consider them a part of our token.
    lexer->mark_end(lexer);

    // skip is not to be used after marking the end of a token, only before the token itself, so "advance" whitespace
    while (iswspace(lexer->lookahead)) {
      lexer->advance(lexer, false);
    }

    if (lexer->lookahead == '\\') {
      lexer->advance(lexer, false);
    } else {
      return false;
    }

    if (lexer->lookahead == '\n' || lexer->lookahead == '$') {
      return true;
    }
  }

  return false;
}
```

This exactly parses the scenario described above