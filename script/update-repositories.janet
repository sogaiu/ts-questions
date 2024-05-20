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

(def orig-dir (os/cwd))

(def problems @[])

(eachp [root _] repos-roots  
  (os/cd root)
  (print root)
  (def res (os/execute ["git" "pull"] :p))
  (when (not (zero? res))
    (array/push problems root)
    (eprintf "git pull error for: %s" root))
  (os/cd orig-dir))

(when (pos? (length problems))
  (print "The following paths had some issue with updating:")
  (each issue problems
    (print issue)))
