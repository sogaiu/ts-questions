# XXX: execute from ts-questions root directory

(import ./walk-dir :as wd)

(def repos-roots @{})

(def all-repos-root "./repos")

(wd/visit-dirs
  all-repos-root
  (fn [path]
    (when (string/has-suffix? "/.git" path)
      (def parent-dir
        (string/slice path 0 (- (inc (length "/.git")))))
      (put repos-roots parent-dir true))))

(def no-parser-c (table/clone repos-roots))

(eachp [root _] repos-roots
  (wd/visit-files
    root
    (fn [path]
      (when (string/has-suffix? "src/parser.c" path)
        (put no-parser-c root nil)))))

(eachp [root _] no-parser-c
  '(def relative-root
    (string/slice root (inc (length all-repos-root))))
  '(print relative-root)
  (print root))

(printf "Repositories lacking parser.c: %d" (length no-parser-c))
(printf "Number of repositories: %d" (length repos-roots))

