#!/usr/bin/env bash

repos_root=../..

dir=$(pwd)

n_scanner_c=0
n_scanner_cc=0

test_script=$(
	cat <<EOF
#!/usr/bin/env sh

set -eu

ROOT_DIR="fuzzer"

LANG=\$1
TIME=\$2
CPP=\$3
# if scanner = scanner.cc then XFLAG = c++ else XFLAG = c
if [ "\$CPP" = "cpp" ]; then
	SCANNER="scanner.cc"
	XFLAG="c++"
else
	SCANNER="scanner.c"
	XFLAG="c"
fi

shift 3

export PATH="/root/.cargo/bin:\$PATH"
export CFLAGS="\$(pkg-config --cflags --libs tree-sitter) -O0 -g -w"

JQ_FILTER='.. | if .type? == "STRING" or (.type? == "ALIAS" and .named? == false) then .value else null end'

build_dict() {
	jq "\$JQ_FILTER" <src/grammar.json |
		grep -v "\\\\\\\\" | grep -v null |
		iconv -c -f UTF-8 -t ASCII//TRANSLIT |
		awk '!/^""\$/' >"\$ROOT_DIR/dict"
}

build_fuzzer() {
	cat <<END | clang -fsanitize=fuzzer,address \$CFLAGS -lstdc++ -g -x \$XFLAG - src/\$SCANNER src/parser.c \$@ -o \$ROOT_DIR/fuzzer
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
./fuzzer -dict=dict -timeout=1 -max_total_time=\$TIME out/
EOF
)

successes=()
fails=()

for r in "${repos_root}"/repos/tree-sitter-*; do
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
		echo "$test_script" >fuzz.sh
		# make it executable
		chmod +x fuzz.sh
		# run the test script, it should be ./fuzz.sh <language> <time>
		lang=$(basename "${r}" | tr '/' '\n' | grep 'tree-sitter-' | cut -d '-' -f 3- | cut -d '.' -f 1 | tr '-' '_')
		echo "Fuzzing ${lang}..., arg=${fuzz_arg}"
		echo "Command= ./fuzz.sh ${lang} 1 ${fuzz_arg}"
		if ./fuzz.sh "$lang" 1 "$fuzz_arg"; then
			echo "Fuzzing done for ${lang}"
			successes+=("${lang}")
		else
			echo "Fuzzing failed for ${lang}"
			fails+=("${lang}")
		fi
		cd "${dir}" || exit 1
	fi

	for _ in */src/scanner.cc; do
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
			echo "$test_script" >fuzz.sh
			# make it executable
			chmod +x fuzz.sh
			# run the test script, it should be ./fuzz.sh <language> <time>
			lang=$(basename "${r}" | tr '/' '\n' | grep 'tree-sitter-' | cut -d '-' -f 3- | cut -d '.' -f 1 | tr '-' '_')
			echo "Fuzzing ${lang}..., arg=${fuzz_arg}"
			echo "Command= ./fuzz.sh ${lang} 1 ${fuzz_arg}"
			if ./fuzz.sh "$lang" 1 "$fuzz_arg"; then
				echo "Fuzzing done for ${lang}"
				successes+=("${lang}")
			else
				echo "Fuzzing failed for ${lang}"
				fails+=("${lang}")
			fi
			cd "${dir}" || exit 1
		fi
	done
done

echo "Successes: ${successes[*]}"
echo "Fails: ${fails[*]}"
