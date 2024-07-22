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
      (put repos-roots parent-dir true))))

(def orig-dir (os/cwd))

(def problems @[])

(eachp [root _] repos-roots  
  (os/cd root)
  (print root)
  (def res (os/execute ["git" "pull" "--depth" "1"] :p))
  (cond
    # XXX: better handling would examine output as well to determine
    #      how to respond?
    (= 128 res)
    (do
      # XXX: following two things seem to help in divergent branches case
      #      where the original clone was shallow
      (os/execute ["git" "pull" "--unshallow"] :px)
      (os/execute ["git" "merge" "--allow-unrelated-histories"] :px))
    #
    (when (not (zero? res))
      (array/push problems root)
      (eprintf "git pull error for: %s" root)
      (eprintf "git exit code: %d" res)))
  (os/cd orig-dir))

(when (pos? (length problems))
  (print "The following paths had some issue with updating:")
  (each issue problems
    (print issue)))
