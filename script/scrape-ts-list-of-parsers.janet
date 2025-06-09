#! /usr/bin/env janet

# XXX: execute this script from ts-questions root directory

(import ./common :as c)

# input
c/ts-lop-fname

# output
c/ts-g-fname

########################################################################

(defn main
  [& args]
  (when (not (os/stat "README.md"))
    (eprint "please execute from ts-questions root directory")
    (os/exit 1))

  (try (os/stat c/ts-lop-fname)
    ([e] (eprint e) (os/exit 1)))

  (def lop-peg
    ~{:main (sequence (some :line) -1)
      :line (choice :repo-line :other-line)

      :repo-line (sequence "|" (to "[")
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
        (try (slurp c/ts-lop-fname)
          ([e] (eprint e) (os/exit 1))))
      (string content
              # wiki page lacked newline at eof (at some point)
              (when (not= "\n" (last content))
                "\n"))))

  (def repo-urls
    (peg/match lop-peg lop-content))

  (assert repo-urls "failed to parse list of parsers")

  (with [of (file/open c/ts-g-fname :w)]
    (each url (sort repo-urls)
      (file/write of url)
      (file/write of "\n"))))

