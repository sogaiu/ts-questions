# XXX: execute from ts-questions root directory

(import ./walk-dir :as wd)
(import ./common :as c)
(import ./utils :as u)

########################################################################

(def results @{})

(wd/visit-files
  c/all-repos-root
  (fn [path]
    (when (string/has-suffix? "src/parser.c" path)
      (def abi (u/find-abi-level path))
      (assertf abi "did not determine abi from %s")
      (put results abi
           (array/push (get results abi @[]) path)))))

(print "ABI: Count")
(print)

(var hits 0)

(each level (sort (keys results))
  (def n-results (length (get results level)))
  (printf "%d: %d" level n-results)
  (+= hits n-results))

(print)
(printf "Total found: %d" hits)

