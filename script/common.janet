(def all-repos-root "./repos")

(def t-g-fname "ts-grammar-repositories.txt")

(def parser-rows-path "./parser-rows.jdn")

(def parsers-tsv-fname "parsers.tsv")
(def gfm-table-fname "ts-parsers-gfm-table.md")

(def repos-skip-list-fname "repos-skip-list.txt")

########################################################################

(def ts-lop-url
  (string "https://raw.githubusercontent.com/wiki/tree-sitter/"
          "tree-sitter/List-of-parsers.md"))
(def ts-lop-fname "tree-sitter.List-of-parsers.md")
(def ts-g-fname "tree-sitter-grammar-urls.txt")

(def nt-url
  (string "https://raw.githubusercontent.com/nvim-treesitter/"
          "nvim-treesitter/refs/heads/main/"
          "SUPPORTED_LANGUAGES.md"))
(def nt-lop-fname "nvim-treesitter.SUPPORTED_LANGUAGES.md")
(def nt-g-fname "nvim-treesitter-grammar-urls.txt")

########################################################################

# potential column names
(def col-info
  [:name
   :url
   :repos-dir
   :last-commit-date
   :last-commit-hash
   :tree-sitter-json
   :grammar-dir
   :abi
   :parser-c
   :grammar-json
   :scanner])

