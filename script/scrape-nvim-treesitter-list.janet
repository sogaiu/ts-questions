#! /usr/bin/env janet

# XXX: execute this script from ts-questions root directory

(import ./common :as c)

# input
c/nt-lop-fname

# output
c/ntgr-fname

########################################################################

(when (not (os/stat "README.md"))
  (eprint "please execute from ts-questions root directory")
  (os/exit 1))

(try (os/stat c/nt-lop-fname)
  ([e] (eprint e) (os/exit 1)))

(def lop-peg
  ~{:main (sequence (some :line) -1)
    :line (choice :repo-line :other-line)

    :repo-line (sequence (to "[")
                         "[" (thru "]")
                         "(" :repo-url ")"
                         (to :eol)
                         :eol)
    :repo-url (capture (sequence "https://"
                                 (thru "/")
                                 (thru "/")
                                 (to ")")))
    :other-line (thru :eol)
    :eol (choice "\r\n" "\n" "\r")})

(def lop-content
  (do
    (def content
      (try (slurp c/nt-lop-fname)
        ([e] (eprint e) (os/exit 1))))
    (string content
            # wiki page lacked newline at eof (at some point)
            (when (not= "\n" (last content))
              "\n"))))

(def repo-urls
  (peg/match lop-peg lop-content))

(assert repo-urls "failed to parse list of parsers")

(with [of (file/open c/ntgr-fname :w)]
  (each url (sort repo-urls)
    (file/write of url)
    (file/write of "\n")))

# XXX: jinja grammar has grammar.js in repository root that isn't for a
#      particular grammar.  this doesn't work well with the method used
#      by collect-and-report.janet (though all other grammars (> 500) work
#      fine.
(eprint "Remember to remove one of the jinja grammars for the time being.")

