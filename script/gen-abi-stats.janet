# XXX: execute from ts-questions root directory

(import ./walk-dir :as wd)
(import ./common :as c)

(defn find-lang-version
  [line]
  (def parsed
    (peg/match ~(sequence :s* "#define"
                          :s+ "LANGUAGE_VERSION"
                          :s+ (capture :d+))
               line))
  (when parsed
    (get parsed 0)))

(comment

  (find-lang-version
    ``
    #define LANGUAGE_VERSION 14
    ``)
  # =>
  "14"

  )

########################################################################

# don't look at more than the first 30 lines
(def n-lines 30)

(def results @{})

(wd/visit-files
  c/all-repos-root
  (fn [path]
    (when (string/has-suffix? "src/parser.c" path)
      (with [f (file/open path)]
        (var nth 0)
        (while (def line (file/read f :line))
          (++ nth)
          (def result (find-lang-version line))
          (when result
            (def level (scan-number result))
            (assert level
                    (string/format "level not a number: %s for %s in %s"
                                   level line path))
            (put results level
                 (array/push (get results level @[]) path))
            (break))
          (when (= nth n-lines)
            (break)))))))

(print "ABI: Count")
(print)

(var hits 0)

(each level (sort (keys results))
  (def n-results (length (get results level)))
  (printf "%d: %d" level n-results)
  (+= hits n-results))

(print)
(printf "Total found: %d" hits)
