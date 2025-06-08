#! /usr/bin/env janet

# XXX: execute from ts-questions root directory

# produce gfm table of info collected from cloned grammar repos

########################################################################

(import ./common :as c)
(import ./utils :as u)

########################################################################

# tuple of triples (one for each field to put in table output)
#
# * keyword
# * label (for output)
# * transform fn (for output)

# for gfm output
(def field-info
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

(defn report
  [rows field-info]
  (def names
    (map (fn [[_ label _]] label)
         field-info))

  (def header-row
    (string/format "| %s | %s | %s | %s | %s | %s |"
                   ;names))

  (print header-row)

  (def separator-row "| --- | --- | --- | --- | --- | --- |")

  (print separator-row)

  (def format-str "| %s | %s | %s | %s | %s | %s |")

  (each r rows
    (u/print-row r field-info format-str)))

########################################################################

(defn main
  [& args]
  (def parser-rows-path
    (if (> (length args) 1)
      (get args 1)
      c/parser-rows-path))

  (assertf (= :file (os/stat parser-rows-path :mode))
           "parsers-rows-path is not a file: %s" parser-rows-path)

  (def rows (parse (slurp parser-rows-path)))

  (assertf (indexed? rows)
           "rows was not an indexed type: %n" (type rows))

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
            sorted-rows))

  (report filtered field-info))

