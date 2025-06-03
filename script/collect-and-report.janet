# XXX: execute from ts-questions root directory

# produce tsv table of info collected from cloned grammar repositories
# see `header-info` below for hints on what each row contains

########################################################################

(import ./common :as c)
(import ./utils :as u)

########################################################################

(def header-info
  @[["url" "%s"]
    ["last commit date" "%s"]
    ["tree-sitter.json" "%s"]
    ["grammar-dir" "%s"]
    ["abi" "%d"]
    ["parser.c" "%s"]
    ["grammar.json" "%s"]
    ["scanner" "%s"]])

########################################################################

(defn collect
  [root-path]
  (def repos-roots
    (u/find-repos-roots root-path |@{}))

  (eachp [rr rr-tbl] repos-roots
    (def url (u/extract-repo-url rr))
    (assertf url "no url determined for: %s" rr)
    (put rr-tbl :url url)
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
      (put g-tbl :dir (u/relativize rr grammar-dir))
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
          (eprintf "multiple files starting with scanner. found for %s: %n"
                   grammar-dir non-o))
        # XXX: just report first one
        (put g-tbl :scanner (first non-o)))
      #
      (array/push gs-array g-tbl))
    #
    (put rr-tbl :grammars gs-array))
  #
  repos-roots)

(defn report
  [repos-roots]
  (def header-row
    (string/join (map |(get $ 0) header-info)
                 "\t"))

  (print header-row)

  (def format-str
    (string/join (map |(get $ 1) header-info)
                 "\t"))

  (eachp [rr rr-tbl] repos-roots
    (def {:url url
          :last-commit-date lc-date
          :tree-sitter-json has-tsj
          :grammars grammars} rr-tbl)
    (default has-tsj :no)
    (each g grammars
      (def {:dir grammar-dir
            :abi abi
            :parser-c has-pc
            :grammar-json has-gjson
            :scanner scanner} g)
      (default abi 0)
      (default has-pc :no)
      (default has-gjson :no)
      (default scanner :no)
      (try
        (printf format-str
                url lc-date has-tsj
                grammar-dir abi has-pc has-gjson scanner)
        ([e]
          (eprintf "%n %n" rr rr-tbl)
          (errorf "problem printing row: %s" e))))))

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

  (report repos-roots))

