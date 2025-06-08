#! /usr/bin/env janet

# XXX: execute from ts-questions root directory

# visit cloned grammar repos, collect info, save to c/parser-rows-path

########################################################################

(import ./common :as c)
(import ./utils :as u)

########################################################################

(def skip-table
  (->> (slurp "./repos-skip-list.txt")
       (string/split "\n")
       (filter |(and (not (empty? $))
                     (string/has-prefix? "https://" $)))
       (map |[$ 0])
       from-pairs))

########################################################################

(defn collect
  [root-path]
  (def repos-roots
    (u/find-repos-roots root-path |@{}))

  (eachp [rr rr-tbl] repos-roots
    (def url (u/extract-repo-url rr))
    (assertf url "no url determined for: %s" rr)
    # only continue if not in skip list
    (when (get skip-table url)
      # remove
      (put repos-roots rr nil)
      (update skip-table url inc)
      (eprintf "skipping %s" url))
    #
    (when (not (get skip-table url))
      (put rr-tbl :repos-dir rr)
      #
      (put rr-tbl :url url)
      #
      (def lc-hash (u/last-commit-hash rr))
      (assertf (not (empty? lc-hash)) "no last commit hash for: %s" rr)
      (put rr-tbl :last-commit-hash lc-hash)
      #
      (def lc-date (u/last-commit-date rr))
      (assertf (not (empty? lc-date)) "no last commit date for: %s" rr)
      (put rr-tbl :last-commit-date lc-date)
      #
      (def tsjs (u/find-tree-sitter-json rr))
      (when (> (length tsjs) 1)
        (eprintf "multiple tree-sitter.json files found for %s" rr))
      (when (not (empty? tsjs))
        (put rr-tbl :tree-sitter-json :yes))
      #
      (def grammar-js-paths (u/find-grammar-js rr))
      (when (empty? grammar-js-paths)
        (eprintf "no grammars found for %s" rr))
      #
      (def gs-array @[])
      (each p grammar-js-paths
        (def g-tbl @{})
        #
        (def grammar-dir
          (string/slice p 0 (- (inc (length "/grammar.js")))))
        (put g-tbl :grammar-dir (u/relativize rr grammar-dir))
        #
        (def name (u/find-name grammar-dir))
        (assertf name "did not determine name for: %s" grammar-dir)
        (put g-tbl :name name)
        #
        (def parser-c-path (string grammar-dir "/src/parser.c"))
        (when (os/stat parser-c-path :mode)
          (put g-tbl :parser-c :yes)
          #
          (def abi (u/find-abi-level parser-c-path))
          (assertf abi "did not determine abi from %s" parser-c-path)
          (put g-tbl :abi abi))
        #
        (def grammar-json-path (string grammar-dir "/src/grammar.json"))
        (when (os/stat grammar-json-path :mode)
          (put g-tbl :grammar-json :yes))
        #
        (def scanners (u/find-scanner-likes grammar-dir))
        (when (not (empty? scanners))
          (def non-o (filter |(not= "o" $) scanners))
          (when (> (length non-o) 1)
            (eprintf "grammar-dir: %s" grammar-dir)
            (eprintf "> 1 filenames start with 'scanner.' for %s: %n"
                     grammar-dir non-o))
          # XXX: just report first one
          (put g-tbl :scanner (first non-o)))
        #
        (array/push gs-array g-tbl))
      #
      (put rr-tbl :grammars gs-array)))
  #
  repos-roots)

(defn make-rows
  [repos-roots]
  (def rows @[])
  (def seen-names @{})
  (eachp [rr rr-tbl] repos-roots
    (def {:repos-dir repos-dir
          :url url
          :last-commit-date lc-date
          :last-commit-hash lc-hash
          :tree-sitter-json has-tsj
          :grammars grammars} rr-tbl)
      (default has-tsj :no)
      (each g grammars
        (def {:name name
              :grammar-dir grammar-dir
              :abi abi
              :parser-c has-pc
              :grammar-json has-gjson
              :scanner scanner} g)
        (def hashes (get seen-names name @{}))
        (when (not (get hashes lc-hash))
          (put-in seen-names [name lc-hash] true)
          (default abi 0)
          (default has-pc :no)
          (default has-gjson :no)
          (default scanner :no)
          (array/push rows
                      {:name name
                       :url url
                       :repos-dir repos-dir
                       :last-commit-date lc-date
                       :last-commit-hash lc-hash
                       :tree-sitter-json has-tsj
                       :grammar-dir grammar-dir
                       :abi abi
                       :parser-c has-pc
                       :grammar-json has-gjson
                       :scanner scanner}))))
  #
  rows)

########################################################################

(defn main
  [& args]
  (def root-path
    (if (> (length args) 1)
      (get args 1)
      c/all-repos-root))

  (assertf (= :directory (os/stat root-path :mode))
           "root-path is not a directory: %s" root-path)

  (def repos-roots (collect root-path))

  (def rows (make-rows repos-roots))
  
  (with [of (file/open c/parser-rows-path :w)]
    (xprintf of "%m" rows))

  (printf "%d repositories" (length repos-roots))
  (printf "%d skipped" (reduce + 0 (values skip-table)))
  (printf "%d grammar rows" (length rows)))

