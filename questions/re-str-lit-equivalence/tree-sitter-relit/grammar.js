module.exports = grammar({
  name: 'relit',

  rules: {
    source: ($) =>
      /[\/]/,            // <--- regex literal

  }
});
