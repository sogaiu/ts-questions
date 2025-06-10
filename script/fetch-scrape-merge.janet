#! /usr/bin/env janet

(import ./utils :as u)

(import ./fetch-nvim-treesitter-list :as fn)
(import ./scrape-nvim-treesitter-list :as sn)

(import ./fetch-tree-sitter-list :as ft)
(import ./scrape-tree-sitter-list :as st)

(import ./merge-lists-of-parsers :as m)

########################################################################

(print "Fetching nvim-treesitter list...")
(fn/main [])
(u/pause)

(print "Scraping results...")
(sn/main [])
(u/pause)

(print "Fetching tree-sitter list...")
(ft/main [])
(u/pause)

(print "Scraping results...")
(st/main [])
(u/pause)

(print "Merging...")
(m/main [])
(u/pause false)

