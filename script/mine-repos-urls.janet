# XXX: execute from ts-questions root directory

(import ./common :as c)
(import ./utils :as u)

########################################################################

(def repos-roots
  (u/find-repos-roots c/all-repos-root))

(def results @[])

(eachp [root _] repos-roots
  (when-let [url (u/extract-repo-url root)]
    (array/push results [root url])))

(sort-by |(get $ 1) results)

(each [_ url] results
  (print url))

