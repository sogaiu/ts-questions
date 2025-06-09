#! /usr/bin/env janet

# XXX: execute from ts-questions root directory

(import ./common :as c)
(import ./utils :as u)

########################################################################

(def content (u/fetch-url c/nts-url))

(spit c/nt-lop-fname content)

