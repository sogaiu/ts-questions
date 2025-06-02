# XXX: execute from ts-questions root directory

(import ./common :as c)
(import ./utils :as u)

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

(def repos-roots
  (u/find-repos-roots c/all-repos-root))

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

(sort-by |(get $ 1) results)

(each [_ url] results
  (print url))

