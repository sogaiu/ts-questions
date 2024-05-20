# XXX: execute from ts-questions root directory

(import ./walk-dir :as wd)

(def results @{})

(var n-grammars 0)

(def all-repos-root "./repos")

(wd/visit-files
  all-repos-root
  (fn [path]
    (cond
      (string/has-suffix? "/grammar.js" path)
      (++ n-grammars)
      #
      (string/has-suffix? "src/scanner.c" path)
      (put results :c
           (array/push (get results :c @[]) path))
      #
      (string/has-suffix? "src/scanner.cc" path)
      (put results :cc
           (array/push (get results :cc @[]) path)))))

(def num-c (length (get results :c)))
(def num-cc (length (get results :cc)))

(each path (sort (get results :c))
  '(def relative-path
    (string/slice path (inc (length all-repos-root))))
  '(print relative-path)
  (print path))

(each path (sort (get results :cc))
  '(def relative-path
    (string/slice path (inc (length all-repos-root))))
  '(print relative-path)
  (print path))

(printf "Grammars with scanner.c: %d" num-c)
(printf "Grammars with scanner.cc: %d" num-cc)
(printf "Total scanner source files: %d" (+ num-c num-cc))
(printf "Total number of grammar.js: %d" n-grammars)
