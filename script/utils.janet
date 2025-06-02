(import ./walk-dir :as wd)

(defn find-repos-roots
  [root &opt dflt-fn]
  (default dflt-fn |true)
  (def repos-roots @{})
  (wd/visit-dirs
    root
    (fn [path]
      (when (string/has-suffix? "/.git" path)
        (def parent-dir
          (string/slice path 0 (- (inc (length "/.git")))))
        (put repos-roots parent-dir (dflt-fn)))))
  #
  repos-roots)

