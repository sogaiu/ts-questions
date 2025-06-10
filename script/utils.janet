(import ./walk-dir :as wd)

'(defn find-repos-roots-candidate
  [root &opt dflt-fn action-fn]
  (default dflt-fn |true)
  (def repos-roots @{})
  (wd/visit-dirs
    root
    (fn [path]
      (when (string/has-suffix? "/.git" path)
        (def parent-dir
          (string/slice path 0 (- (inc (length "/.git")))))
        (put repos-roots parent-dir (dflt-fn))
        (when action-fn
          (action-fn {:repos-roots repos-roots
                      :path path
                      :parent-dir parent-dir})))))
  #
  repos-roots)

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

########################################################################

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

  (find-repo-url
    "        url = https://github.com/tree-sitter/tree-sitter-c")
  # =>
  "https://github.com/tree-sitter/tree-sitter-c"

  )

(defn extract-repo-url
  [repos-root]
  (def config-path (string repos-root "/.git/config"))
  (assertf (os/stat config-path :mode)
           "git config file not found at %s" config-path)
  (var url nil)
  (with [f (file/open config-path)]
    (while (def line (file/read f :line))
      (def result (find-repo-url line))
      (when result
        (set url result)
        (break))))
  #
  url)

########################################################################

(defn last-commit-date
  [repos-root]
  (def old-dir (os/cwd))
  (def buf @"")
  (defer (os/cd old-dir)
    (os/cd repos-root)
    (with [of (file/temp)]
      (os/execute ["git" "--no-pager"
                   "log" "-1" `--format=%as`]
                  :px {:out of})
      (file/seek of :set 0)
      (file/read of :all buf)))
  #
  (string/trimr buf))

(comment

  (last-commit-date (string (os/getenv "HOME") "/src/janet"))

  )

########################################################################

(defn last-commit-hash
  [repos-root]
  (def old-dir (os/cwd))
  (def buf @"")
  (defer (os/cd old-dir)
    (os/cd repos-root)
    (with [of (file/temp)]
      (os/execute ["git" "--no-pager" "rev-parse" "HEAD"]
                  :px {:out of})
      (file/seek of :set 0)
      (file/read of :all buf)))
  #
  (string/trimr buf))

(comment

  (last-commit-hash (string (os/getenv "HOME") "/src/janet"))

  )

########################################################################

(defn find-tree-sitter-json
  [repos-root]
  (def results @[])
  (wd/visit-files
    repos-root
    (fn [path]
      (when (string/has-suffix? "/tree-sitter.json" path)
        (array/push results path))))
  #
  results)

(comment

  (find-tree-sitter-json
    (string (os/getenv "HOME") "/src/tree-sitter-janet-simple"))

  )

########################################################################

(defn find-grammar-js
  [repos-root]
  (def results @[])
  (wd/visit-files
    repos-root
    (fn [path]
      (when (string/has-suffix? "/grammar.js" path)
        (array/push results path))))
  #
  results)

(comment

  (find-grammar-js
    (string (os/getenv "HOME") "/src/tree-sitter-janet-simple"))

  )

########################################################################

(defn find-lang-name
  [line]
  (def parsed
    (peg/match ~(sequence :s*
                          # .js and .json
                          (choice "name:" `"name":`)
                          :s+
                          (choice `"` "'")
                          (capture (to (choice `"` "'")))
                          (choice `"` "'"))
               line))
  (when parsed
    (get parsed 0)))

(comment

  (find-lang-name
    ``
      name: "python_legesher",
    ``)
  # =>
  "python_legesher"

  (find-lang-name
    ``
      name: 'ssh_client_config',
    ``)
  # =>
  "ssh_client_config"

  (find-lang-name
    ``
      "name": "hcl",
    ``)
  # =>
  "hcl"

  )

(defn scan-file-for-name
  [path]
  (var name nil)
  (with [f (file/open path)]
    (while (def line (file/read f :line))
      (def result (find-lang-name line))
      (when result
        (set name result)
        (break))))
  #
  name)

(defn find-name
  [grammar-dir]
  (var name nil)
  #
  (def grammar-js-path (string grammar-dir "/grammar.js"))
  (assertf (= :file (os/stat grammar-js-path :mode))
           "grammar.js does not exist for: %s" grammar-dir)
  #
  (set name (scan-file-for-name grammar-js-path))
  (when name (break name))
  #
  (def grammar-json-path (string grammar-dir "/src/grammar.json"))
  (when (= :file (os/stat grammar-json-path :mode))
    (set name (scan-file-for-name grammar-json-path)))
  #
  # XXX: it's possible to reach this point without having succeeded
  #      in determining a name.
  #
  #      some other things that could be tried:
  #
  #      * substring repository url
  #      * look in package.json (may need to massage name)
  #      * look in tree-sitter.json (not present in many cases)
  #
  #      not likely to work:
  #
  #      * scan parser.c - if the grammar.json approach didn't
  #        work, then it's likely because grammar.json didn't
  #        exist.  in such cases, it's not likely that parser.c
  #        exists.
  #
  name)

########################################################################

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

(defn find-abi-level
  [parser-c-path]
  # don't look at more than the first 30 lines
  (def n-lines 30)
  #
  (var abi nil)
  #
  (with [f (file/open parser-c-path)]
    (var nth 0)
    (while (def line (file/read f :line))
      (++ nth)
      (def result (find-lang-version line))
      (when result
        (def level (scan-number result))
        (assert level
                (string/format "level not a number: %s for %s in %s"
                               level line parser-c-path))
        (set abi level)
        (break))
      (when (= nth n-lines)
        (break))))
  #
  abi)

(comment

  (find-abi-level
    (string (os/getenv "HOME")
            "/src/tree-sitter-janet-simple"
            "/src/parser.c"))

  )

########################################################################

(def rev-pattern (reverse "/src/scanner."))

(defn find-scanner-likes
  [dir]
  (def results @[])
  (def src-dir (string dir "/src"))
  (when (= :directory (os/stat src-dir :mode))
    (each p (os/dir src-dir)
      (def path (string src-dir "/" p))
      (def rev-path (reverse path))
      (def m (peg/match ~(capture (to ,rev-pattern))
                        rev-path))
      (when-let [[rev-ext] m]
        (array/push results (string (reverse rev-ext))))))
  #
  results)

(comment

  (find-scanner-likes
    (string (os/getenv "HOME") "/src/tree-sitter-janet-simple"))

  )

########################################################################

(defn relativize
  [root sub]
  (string "." (string/slice sub (length root))))

(comment

  (relativize "./repos/github.com/ribru17/tree-sitter-readline"
              "./repos/github.com/ribru17/tree-sitter-readline/src/parser.c")
  # =>
  "./src/parser.c"

  (relativize "./repos/github.com/ribru17/tree-sitter-readline"
              "./repos/github.com/ribru17/tree-sitter-readline")
  # =>
  "."

  )

########################################################################

# given two arrays, check whether the first array contains all of the
# values of the second array
(defn has-values?
  [arr-1 arr-2]
  # handle looking for nil first
  (when (find-index nil? arr-2)
    (when (not (find-index nil? arr-1))
      (break false)))
  #
  (def tbl-1 (from-pairs (map |[$ $] arr-1)))
  (var all-found? true)
  (each val arr-2
    (when (and (not (nil? val))
               (not (get tbl-1 val)))
      (set all-found? false)
      (break)))
  #
  all-found?)

(comment

  (has-values? [:a :b] [:b])
  # =>
  true

  (has-values? [:a] [:b])
  # =>
  false

  (has-values? [nil] [nil])
  # =>
  true

  (has-values? [:a] [nil])
  # =>
  false

  )

(defn assert-keys
  [row-keys field-info-keys]
  (assertf (has-values? row-keys field-info-keys)
           (string "\n"
                   "  row keys:\n"
                   "    %n\n"
                   "  missing something from:\n"
                   "    %n")
           row-keys field-info-keys))

########################################################################

(defn print-row
  [of row field-info format-str]
  # massage field values for output
  (def vals
    (map (fn [[id _ xform]] (xform (get row id)))
         field-info))
  (try
    (xprintf of format-str ;vals)
    ([e]
      (eprintf "%n" row)
      (errorf "problem printing row: %s" e))))

########################################################################

(defn fetch-url
  [url]
  (with [of (file/temp)]
    (os/execute ["curl" url] :px {:out of})
    (file/seek of :set 0)
    (file/read of :all)))

(comment

  (fetch-url "https://janet-lang.org/")

  )

########################################################################

(defn pause
  [&opt query?]
  (default query? true)
  (print "Consider reviewing differences via git.")
  (when query?
    (def resp @"")
    (var done false)
    (while (not done)
      (getline "Continue? [Y/n] " resp)
      (def lower (string/ascii-lower (string/trim resp)))
      (cond
        (or (empty? lower)
            (string/has-prefix? "y" lower))
        (set done true)
        #
        (string/has-prefix? "n" lower)
        (os/exit 0)))))

