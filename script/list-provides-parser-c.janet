# XXX: execute from ts-questions root directory

(import ./walk-dir :as wd)
(import ./common :as c)

(def results @[])

(var n-grammars 0)

(def all-repos-root "./repos")

(wd/visit-files
  c/all-repos-root
  (fn [path]
    (cond
      (string/has-suffix? "/grammar.js" path)
      (++ n-grammars)
      #
      (string/has-suffix? "src/parser.c" path)
      (array/push results path))))

(each root results
  (print root))

(printf "Grammars with parser.c: %d" (length results))
(printf "Total number of grammar.js: %d" n-grammars)

