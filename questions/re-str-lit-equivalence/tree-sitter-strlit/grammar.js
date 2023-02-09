module.exports = grammar({
  name: 'strlit',

  rules: {
    source: ($) =>
      RegExp("[/]"),     // <--- string literal

  }
});
