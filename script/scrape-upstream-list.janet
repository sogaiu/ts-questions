#! /usr/bin/env janet

# XXX: clone nvim-treesitter.wiki as a subdirectory
# XXX: execute this script from ts-questions root directory

# input
(def lop-fname "nvim-treesitter.wiki/List-of-parsers.md")

# output
(def repos-fname "ts-grammar-repositories.txt")

########################################################################

(when (not (os/stat "README.md"))
  (eprint "please execute from ts-questions root directory")
  (os/exit 1))

(try (os/stat lop-fname)
  ([e] (eprint e) (os/exit 1)))

(def lop-peg
  ~{:main (sequence (some :line) -1)
    :line (choice :repo-line :other-line)
    :repo-line (sequence "- [" 1 "] "
                         "[" (thru "]")
                         "(" :repo-url ")"
                         :eol)
    :repo-url (capture (sequence "https://"
                                 (thru "/")
                                 (thru "/")
                                 (to ")")))
    :other-line (thru :eol)
    :eol (choice "\r\n" "\n" "\r")})

(def lop-content
  (try (slurp lop-fname)
    ([e] (eprint e) (os/exit 1))))

(def repo-urls
  (peg/match lop-peg lop-content))

(assert repo-urls "failed to parse list of parsers")

(with [of (file/open repos-fname :w)]
  (def seen-table @{})
  (each url (sort repo-urls)
    (when (not (get seen-table url))
      (put seen-table url true)
      (file/write of url)
      (file/write of "\n"))))

