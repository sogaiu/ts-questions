#!/usr/bin/env bash

repos_root=../..

dir=$(pwd)

n_scanner_c=0
n_scanner_cc=0

timeout="${1:-1}"
max_total_time="${2:-1}"

test_script=$(
    cat <<EOF
#!/usr/bin/env sh

set -eu

ROOT_DIR="fuzzer"

# XXX: ensure shift below is consistent with number of args here
LANG=\$1
TIMEOUT=\$2
MAX_TOTAL_TIME=\$3
CPP=\$4

shift 4

# if scanner = scanner.cc then XFLAG = c++ else XFLAG = c
if [ "\$CPP" = "cpp" ]; then
    COMPILER="clang++"
    SCANNER="scanner.cc"
    XFLAG="c++"
else
    COMPILER="clang"
    SCANNER="scanner.c"
    XFLAG="c"
fi

export CFLAGS="\$(pkg-config --cflags --libs tree-sitter) -O0 -g -w"

JQ_FILTER='.. | if .type? == "STRING" or (.type? == "ALIAS" and .named? == false) then .value else null end'

build_dict() {
    jq "\$JQ_FILTER" <src/grammar.json |
        grep -v "\\\\\\\\" | grep -v null |
        iconv -c -f UTF-8 -t ASCII//TRANSLIT |
        awk '!/^""\$/' >"\$ROOT_DIR/dict"
}

build_fuzzer() {
    cat <<END | \$COMPILER -fsanitize=fuzzer,address,undefined \$CFLAGS -lstdc++ -g -x \$XFLAG - src/\$SCANNER src/parser.c \$@ -o \$ROOT_DIR/fuzzer
#include <stdio.h>
#include <stdlib.h>
#include <tree_sitter/api.h>

#ifdef __cplusplus
extern "C"
#endif
TSLanguage *tree_sitter_\$LANG();

#ifdef __cplusplus
extern "C"
#endif
int LLVMFuzzerTestOneInput(const uint8_t * data, const size_t len) {
  // Create a parser.
  TSParser *parser = ts_parser_new();

  // Set the parser's language.
  ts_parser_set_language(parser, tree_sitter_\$LANG());

  // Build a syntax tree based on source code stored in a string.
  TSTree *tree = ts_parser_parse_string(
    parser,
    NULL,
    (const char *)data,
    len
  );
  // Free all of the heap-allocated memory.
  ts_tree_delete(tree);
  ts_parser_delete(parser);
  return 0;
}
END
}

generate_fuzzer() {
    tree-sitter generate
}

makedirs() {
    rm -rf "\$ROOT_DIR"
    mkdir -p "\$ROOT_DIR"
    mkdir -p "\$ROOT_DIR/out"
}

makedirs
# generate_fuzzer

build_dict
build_fuzzer \$@
cd "\$ROOT_DIR"
./fuzzer -dict=dict -timeout=\$TIMEOUT -max_total_time=\$MAX_TOTAL_TIME out/
EOF
)

n_success=()
n_fail=()

for r in "${repos_root}"/repos/tree-sitter-*; do
    if [ -d "${r}" ]; then
        printf "Processing: %s\n" "${r}"
        cd "${r}" || exit 1
        file_c=src/scanner.c
        file_cc=src/scanner.cc
        if [[ -f "${file_c}" || -f "${file_cc}" ]]; then
            if [[ -f "${file_c}" ]]; then
                lc=$(wc -l <"${file_c}")
                n_scanner_c=$((n_scanner_c + 1))
                fuzz_arg=c
                printf "[%d] %s/%s\n" "${lc}" "$(basename "${r}")" "${file_c}"
            else
                lc=$(wc -l <"${file_cc}")
                n_scanner_cc=$((n_scanner_cc + 1))
                fuzz_arg=cpp
                printf "[%d] %s/%s\n" "${lc}" "$(basename "${r}")" "${file_cc}"
            fi
            # write the test script to fuzz.sh
            printf "%s" "$test_script" > fuzz.sh
            # make it executable
            chmod +x fuzz.sh
            # run script: ./fuzz.sh <lang> <timeout> <max_total_time> <c|cpp>
            lang=$(basename "${r}" | sed -n 's#tree-sitter-\([^.]\+\)\..*#\1#p' | tr '-' '_')
            printf "Fuzzing %s..., arg=%s\n" "${lang}" "${fuzz_arg}"
            printf "Command= ./fuzz.sh %s %s %s %s\n" \
                "${lang}" "${timeout}" "${max_total_time}" "${fuzz_arg}"
            if ./fuzz.sh "$lang" "$timeout" "$max_total_time" "$fuzz_arg" ; then
                printf "Fuzzing done for %s\n" "${lang}"
                n_success+=("${lang}")
            else
                printf "Fuzzing failed for %s\n" "${lang}"
                n_fail+=("${lang}")
            fi
            cd "${dir}" || exit 1
        fi
    fi
done

printf "Succeeded: %s\n" "${n_success[*]}"
printf "Failed: %s\n" "${n_fail[*]}"
