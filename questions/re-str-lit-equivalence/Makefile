TS_RELIT_DIR = tree-sitter-relit
TS_STRLIT_DIR = tree-sitter-strlit

GRAM_JSON_RELIT = $(TS_RELIT_DIR)/src/grammar.json
GRAM_JSON_STRLIT = $(TS_STRLIT_DIR)/src/grammar.json

GRAM_JS_RELIT = $(TS_RELIT_DIR)/grammar.js
GRAM_JS_STRLIT = $(TS_STRLIT_DIR)/grammar.js

.PHONY: demo
demo: $(GRAM_JSON_RELIT) $(GRAM_JSON_STRLIT)
	@printf "Generated grammar.jsons differ\n"
	@printf "%s\n\n" "------------------------------"
	@diff -u --label="$(GRAM_JSON_RELIT)" $(GRAM_JSON_RELIT) \
                 --label="$(GRAM_JSON_STRLIT)" $(GRAM_JSON_STRLIT) || true

.PHONY: full-diff
full-diff: $(GRAM_JSON_RELIT) $(GRAM_JSON_STRLIT)
	@diff -ur --label="$(TS_RELIT_DIR)" $(TS_RELIT_DIR) \
                  --label="$(TS_STRLIT_DIR)" $(TS_STRLIT_DIR) || true

$(GRAM_JSON_RELIT):
	@cd $(TS_RELIT_DIR) && tree-sitter generate --no-bindings

$(GRAM_JSON_STRLIT):
	@cd $(TS_STRLIT_DIR) && tree-sitter generate --no-bindings

.PHONY: show-inputs
show-inputs:
	@printf "Regular Expression Literal\n\n"
	@cat $(GRAM_JS_RELIT)
	@printf "\n%s\n\n" "------------------------------"
	@printf "String Literal\n\n"
	@cat $(GRAM_JS_STRLIT)

.PHONY: count-repos
count-repos:
	@printf "To get grammar repositories, cd to root of this repository,\n"
	@printf "then run ./script/fetch-repositories.sh\n\n"
	@sh ./script/count-uses-regexp.sh

.PHONY: clean
clean:
	rm -rf $(TS_RELIT_DIR)/src
	rm -rf $(TS_STRLIT_DIR)/src
