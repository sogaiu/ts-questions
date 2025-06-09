#! /usr/bin/env janet

# XXX: execute from ts-questions root directory

# produce tsv table of info collected from cloned grammar repos

########################################################################

(import ./common :as c)
(import ./utils :as u)

########################################################################

# tuple of triples (one for each field to put in table output)
#
# * keyword
# * label (for output)
# * transform fn (for output)

# for tsv output
(def field-info
  [# Ada and COBOL...ofc, some old foggies would be using
   # upper case...
   [:name "name" string/ascii-lower]
   [:url "url" identity]
   [:last-commit-date "last commit date" identity]
   [:last-commit-hash "commit hash" identity]
   [:tree-sitter-json "tree-sitter.json" identity]
   [:grammar-dir "grammar dir" identity]
   [:abi "abi" |(if (= 0 $) "-" (string $))]
   # abi 0 implies no src/parser.c, so :parser-c is sort of redundant
   [:parser-c "parser.c" identity]
   [:grammar-json "grammar.json" identity]
   [:scanner "external scanner" identity]])

########################################################################

(defn report
  [of rows field-info]
  (def names
    (map (fn [[_ label _]] label)
         field-info))

  (def header-row (string/join names "\t"))

  (xprint of header-row)

  (def format-str
    (string/join (map (fn [_] "%s") field-info)
                 "\t"))

  (each r rows
    (u/print-row of r field-info format-str)))

########################################################################

(defn main
  [& args]
  (def parser-rows-path
    (if (> (length args) 1)
      (get args 1)
      c/parser-rows-path))

  (assertf (= :file (os/stat parser-rows-path :mode))
           "parser-rows-path is not a file: %s" parser-rows-path)

  (def rows (parse (slurp parser-rows-path)))

  (assertf (indexed? rows)
           "parsed input was not an indexed type: %n" (type rows))

  # XXX: only checking first row's keys
  (u/assert-keys (sort (keys (first rows)))
                 (sort (map |(get $ 0) field-info)))

  # create rows and sort by name and commit date
  (def sorted-rows
    # some language names use upper-case letters...
    (sorted-by |(string (string/ascii-lower (get $ :name))
                        # use string that is not legal in name
                        "-"
                        (get $ :last-commit-date))
               rows))

  (with [of (file/open c/parsers-tsv-fname :w)]
    (report of sorted-rows field-info)))

