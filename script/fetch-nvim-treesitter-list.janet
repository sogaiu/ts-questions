#! /usr/bin/env janet

# XXX: execute from ts-questions root directory

(import ./common :as c)
(import ./utils :as u)

# input
c/nt-url

# output
c/nt-lop-fname

########################################################################

(defn main
  [& args]
  (def content (u/fetch-url c/nt-url))

  (spit c/nt-lop-fname content))

