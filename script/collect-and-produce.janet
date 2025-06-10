#! /usr/bin/env janet

(import ./utils :as u)

(import ./collect :as c)
(import ./make-parsers-tsv :as pt)
(import ./make-ts-parsers-gfm-table :as gt)

########################################################################

(print "Collecting info from repositories...")
(c/main [])
(u/pause)

(print "Producing parsers.tsv...")
(pt/main [])
(u/pause)

(print "Producing ts-parsers-gfm-table.md...")
(gt/main [])
(u/pause false)

