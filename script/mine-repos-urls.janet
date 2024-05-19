# XXX: execute from ts-questions root directory

(import ../lib/walk-dir :as wd)

(defn find-repo-url
  [line]
    (def parsed
    (peg/match ~(sequence :s* "url"
                          :s+ "="
                          :s+ (capture (to -1)))
               line))
  (when parsed
    (string/trim (get parsed 0))))

(comment

  (find-repo-url "        url = https://github.com/tree-sitter/tree-sitter-c")
  # =>
  "https://github.com/tree-sitter/tree-sitter-c"  

  )

########################################################################

(def repos-roots @{})

(def all-repos-root "./repos")

(wd/visit-dirs
  all-repos-root
  (fn [path]
    (when (string/has-suffix? "/.git" path)
      (def parent-dir
        (string/slice path 0 (- (inc (length "/.git")))))
      (put repos-roots parent-dir true))))

(def results @[])

(eachp [root _] repos-roots
  (def config-path
    (string root "/.git/config"))
  (with [f (file/open config-path)]
    (while (def line (file/read f :line))
      (def result (find-repo-url line))
      (when result
        (array/push results [root result])
        (break)))))

(each [_ url] results
  (print url))
