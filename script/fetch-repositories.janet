#! /usr/bin/env janet

# XXX: execute from ts-questions root directory

(def repos-dir "repos")

(def tsgr-fname "ts-grammar-repositories.txt")

########################################################################

(defn mkdir-p
  [dir-path &opt sep]
  (default sep (if (= :windows (os/which)) `\` "/"))
  (each idx (string/find-all sep dir-path)
    (when (< 0 idx)
      (def curr-path (string/slice dir-path 0 idx))
      (when (not (os/stat curr-path))
        (os/mkdir curr-path))))
  (os/mkdir dir-path))

(comment

  (mkdir-p "/tmp/fun/fun2")

  (mkdir-p "/tmp/fun/fun3/")

  (mkdir-p `C:\Users\user\Desktop` `\`)

  )

########################################################################

(when (not (os/stat "README.md"))
  (eprint "please execute from ts-questions root directory")
  (os/exit 1))

(try (os/stat tsgr-fname)
  ([e] (eprint e) (os/exit 1)))

(def tsgr-peg
  ~{:main (sequence (some :line) -1)
    :line (choice :repo-line :other-line)
    :repo-line (sequence :repo-url :eol)
    :repo-url (cmt (sequence "https://"
                             (capture (to "/"))
                             "/"
                             (capture (to "/"))
                             "/"
                             (capture (to :eol)))
                   ,|[$0 $1 $2])
    :other-line (thru :eol)
    :eol (choice "\r\n" "\n" "\r")})

(def tsgr-content
  (try (slurp tsgr-fname)
    ([e] (eprint e) (os/exit 1))))

(def repo-info
  (peg/match tsgr-peg tsgr-content))

(assert repo-info "failed to parse list of parsers")

(def old-dir (os/cwd))

(try (os/mkdir repos-dir)
  ([e] (eprint e) (os/exit 1)))

(try (os/cd repos-dir)
  ([e] (eprint e) (os/exit 1)))

(def sep (if (= :windows (os/which)) `\` "/"))

(def problems @[])

# skip git's prompts
(os/setenv "GIT_TERMINAL_PROMPT" "0")

(each record repo-info
  (def [host user-name repo-name] record)
  (comment print host " " user-name " " repo-name)
  (def dir-path (string/join record sep))
  (when (not (os/stat dir-path))
    (mkdir-p dir-path)
    (def url 
      (string "https://" host "/" user-name "/" repo-name))
    (printf "cloning %s to %s" url dir-path)
    (def res
      (os/execute ["git" "clone" "--depth" "1" url dir-path] :p))
    (when (not (zero? res))
      (array/push problems url)
      (eprintf "git clone failed with: %n" res))))

(when (next problems)
  (eprint "git clone had issues for the following:")
  (each url problems
    (eprint url)))

(try (os/cd old-dir)
  ([e] (eprint e) (os/exit 1)))

(when (next problems)
  (os/exit 1))

