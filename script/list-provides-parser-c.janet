# XXX: execute from ts-questions root directory

(import ../lib/walk-dir :as wd)

(def results @[])

(var n-grammars 0)

(def all-repos-root "./repos")

(wd/visit-files
  all-repos-root
  (fn [path]
    (cond
      (string/has-suffix? "/grammar.js" path)
      (++ n-grammars)
      #
      (string/has-suffix? "src/parser.c" path)
      (array/push results path))))

(printf "Minimum number of grammars with parser.c: %d"
        (length results))
(printf "Total number of grammar.js: %d" n-grammars)

