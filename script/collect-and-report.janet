# XXX: execute from ts-questions root directory

# produce gfm table of info collected from cloned grammar repositories
# (with some commenting / uncommenting, a tsv table can also be made)
#
# see `col-info` below for what each row can potentially contain.
# what is actually put in the table is tweaked via `*-field-info`.

########################################################################

(import ./common :as c)
(import ./utils :as u)

########################################################################

# there is duplication between this and *-field-info, but may be it's
# going too far to try to remove that duplication.  won't for now.
(def col-info
  [:name
   :url
   :last-commit-date
   :last-commit-hash
   :tree-sitter-json
   :grammar-dir
   :abi
   :parser-c
   :grammar-json
   :scanner])

# tuple of triples (one for each field to put in table output)
#
# * keyword
# * label (for output)
# * transform fn (for output)

# for tsv output
(def tsv-field-info
  [# Ada and COBOL...ofc, some old foggies would be using
   # upper case...
   [:name "name" string/ascii-lower]
   [:url "url" identity]
   [:last-commit-date "last commit date" identity]
   [:abi "abi" |(if (= 0 $) "-" (string $))]
   # abi 0 implies no src/parser.c, so :parser-c is sort of redundant
   #[:parser-c "parser.c" identity]
   [:grammar-json "grammar.json" identity]
   [:scanner "external scanner" |(if (= :no $) :no :yes)]])

# for gfm output
(def gfm-field-info
  [# Ada and COBOL...ofc, some old foggies would be using
   # upper case...
   [:name "name" string/ascii-lower]
   [:url "url"
    |(string/format "[%s](%s)"
                    (string/slice $ (inc (length "http://"))) $)]
   [:last-commit-date "last commit date" identity]
   [:abi "abi" |(if (= 0 $) "-" (string $))]
   # abi 0 implies no src/parser.c, so :parser-c is sort of redundant
   #[:parser-c "parser.c" identity]
   [:grammar-json "grammar.json" identity]
   [:scanner "external scanner" |(if (= :no $) :no :yes)]])

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
      (put g-tbl :dir (u/relativize rr grammar-dir))
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
    (put rr-tbl :grammars gs-array))
  #
  repos-roots)

(defn make-rows
  [repos-roots]
  (def rows @[])
  (def seen-names @{})
  (eachp [rr rr-tbl] repos-roots
    (def {:url url
          :last-commit-date lc-date
          :last-commit-hash lc-hash
          :tree-sitter-json has-tsj
          :grammars grammars} rr-tbl)
      (default has-tsj :no)
      (each g grammars
        (def {:name name
              :dir grammar-dir
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
                       :last-commit-date lc-date
                       :last-commit-hash lc-hash
                       :tree-sitter-json has-tsj
                       :dir grammar-dir
                       :abi abi
                       :parser-c has-pc
                       :grammar-json has-gjson
                       :scanner scanner}))))
  #
  rows)

(defn report-tsv
  [rows field-info]
  (def names
    (map (fn [[_ label _]] label)
         field-info))

  (def header-row (string/join names "\t"))

  (print header-row)

  (def format-str
    (string/join (map (fn [_] "%s") field-info)
                 "\t"))

  (each r rows
    # massage field values for output
    (def vals
      (map (fn [[id _ xform]] (xform (get r id)))
           field-info))
    (try
      (printf format-str ;vals)
      ([e]
        (eprintf "%n" r)
        (errorf "problem printing row: %s" e)))))

(defn report-gfm
  [rows field-info]
  (def names
    (map (fn [[_ label _]] label)
         field-info))

  (def header-row
    (string/format "| %s | %s | %s | %s | %s | %s |"
                   ;names))

  (print header-row)

  (def separator-row
    "| --- | --- | --- | --- | --- | --- |")

  (print separator-row)

  (def format-str
    "| %s | %s | %s | %s | %s | %s |")

  (each r rows
    # massage field values for output
    (def vals
      (map (fn [[id _ xform]] (xform (get r id)))
           field-info))
    (try
      (printf format-str ;vals)
      ([e]
        (eprintf "%n" r)
        (errorf "problem printing row: %s" e)))))

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

  # create rows and sort by name and commit date
  (def rows
    # some language names use upper-case letters...
    (sorted-by |(string (string/ascii-lower (get $ :name))
                        (get $ :last-commit-date))
               (make-rows repos-roots)))

  # only keep some rows
  (def filtered
    (filter (fn [{:last-commit-date lc-date
                  :abi abi
                  :scanner scanner}]
              (def year (-> (string/slice lc-date 0 4)
                            scan-number))
              (and # has no external scanner or is in c
                   (or (= :no scanner) (= "c" scanner))
                   # abi >= 12 or undetermined abi
                   (or (>= abi 12) (= abi 0))
                   # 2020-09 is when abi 12 became default in cli
                   (>= year 2020)))
            rows))

  # CAR - didn't want to type COLLECT_AND_REPORT...too long
  (if (os/getenv "CAR_TSV")
    (report-tsv filtered tsv-field-info)
    (report-gfm filtered gfm-field-info)))

