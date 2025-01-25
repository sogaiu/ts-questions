# XXX: execute from ts-questions root directory

(import ./walk-dir :as wd)
(import ./common :as c)

(def repos-roots @{})

(wd/visit-dirs
  c/all-repos-root
  (fn [path]
    (when (string/has-suffix? "/.git" path)
      (def parent-dir
        (string/slice path 0 (- (inc (length "/.git")))))
      (put repos-roots parent-dir @[]))))

(def tree-sitter-json-paths (table/clone repos-roots))

(def in-root @[])

(def in-subdir @{})

(eachp [root _] repos-roots
  (wd/visit-files
    root
    (fn [path]
      (when (string/has-suffix? "/tree-sitter.json" path)
        (def subpath (string/slice path (length root)))
        #
        (if (= subpath "/tree-sitter.json")
          (array/push in-root root)
          (put in-subdir root
               (array/push (get in-subdir root @[])
                           subpath)))
        (put tree-sitter-json-paths root
             (array/push (get tree-sitter-json-paths root @[])
                              subpath))))))

(def none @[])

(eachp [root paths] tree-sitter-json-paths
  (when (empty? paths)
    (array/push none root)))

(print "in root dir")
(each repo (sort in-root)
  (printf "%s" repo))
(print)

(print "in sub dir")
(each repo (sort (keys in-subdir))
  (def paths (get in-subdir repo))
  (each path paths
    (printf "%s: %s" repo path)))
(print)

(print "no tree-sitter.json")
(each repo (sort none)
  (printf "%s" repo))
(print)

(printf "Number with tree-sitter.json in root: %d" (length in-root))
(printf "Number with tree-sitter.json in subdir: %d" (length in-subdir))
(printf "Number without tree-sitter.json: %d" (length none))
(printf "Number of repositories: %d" (length repos-roots))

