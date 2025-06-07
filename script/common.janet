(def all-repos-root "./repos")
(def parser-rows-path "./parser-rows.jdn")
(def tsgr-fname "ts-grammar-repositories.txt")
(def ntgr-fname "nvim-treesitter-grammar-repositories.txt")

# potential column names
(def col-info
  [:name
   :url
   :last-commit-date
   :last-commit-hash
   :tree-sitter-json
   :grammar-dir
   :abi
   :parser-c
   :grammar-json
   :scanner])

