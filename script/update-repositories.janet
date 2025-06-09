# XXX: execute from ts-questions root directory

(import ./common :as c)
(import ./utils :as u)

# input
c/all-repos-root # what to update determined via filesystem content

# output
c/all-repos-root # files and directories created under here

########################################################################

(def repos-roots
  (u/find-repos-roots c/all-repos-root))

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
  (eprint "The following paths had some issue with updating:")
  (each issue problems
    (eprint issue)))

