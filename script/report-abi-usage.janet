# XXX: execute from ts-questions root directory

(import ./common :as c)

# input
c/parser-rows-path

# output
stdout

########################################################################

(defn main
  [& args]

  (def parser-rows-path
    (if (> (length args) 1)
      (get args 1)
      c/parser-rows-path))

  (assertf (= :file (os/stat parser-rows-path :mode))
           "parsers-rows-path is not a file: %s" parser-rows-path)

  (def rows (parse (slurp parser-rows-path)))

  (assertf (indexed? rows)
           "rows was not an indexed type: %n" (type rows))

  (def results
    (reduce (fn [acc {:abi abi}]
              (update acc abi
                      |(if (nil? $) 1 (inc $))))
            @{}
            rows))

  (var n-known 0)

  (each level (sort (keys results))
    (def n-results (get results level))
    (when (not= 0 level)
      (printf "%d: %d" level n-results)
      (+= n-known n-results)))

  (def n-unknown (get results 0))

  (print)
  (printf "Known: %d" n-known)
  (printf "Unknown: %d" n-unknown)
  (print)
  (printf "Total: %d" (+ n-known n-unknown)))

