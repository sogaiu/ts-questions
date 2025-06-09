#! /usr/bin/env janet

# XXX: execute from ts-questions root directory

(import ./common :as c)
(import ./utils :as u)

########################################################################

(def content (u/fetch-url c/ts-lop-url))

(spit c/ts-lop-fname content)

