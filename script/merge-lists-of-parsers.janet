#! /usr/bin/env janet

# XXX: execute from ts-questions root directory

(import ./common :as c)

# inputs
c/ts-g-fname
c/nt-g-fname

# output
c/t-g-fname

########################################################################

(defn main
  [& args]
  (def ts-lop 
    (->> (slurp c/ts-g-fname)
         (string/split "\n")
         (filter |(string/has-prefix? "https://" $))))

  (def nt-lop
    (->> (slurp c/nt-g-fname)
         (string/split "\n")
         (filter |(string/has-prefix? "https://" $))))

  (def lop
    (-> (array/concat @[] ts-lop nt-lop)
        sort
        distinct))

  (def seen-urls
    (from-pairs (map |[$ true] lop)))

  (with [of (file/open c/t-g-fname :w)]
    (each url lop
      # check for urls that are the same modulo ending with .git
      (if (string/has-suffix? ".git" url)
        (let [dot-git-trimmed 
              (string/slice url 0 (- (inc (length ".git"))))]
          (when (not (get seen-urls dot-git-trimmed))
            (xprint of url)))
        (xprint of url)))))

