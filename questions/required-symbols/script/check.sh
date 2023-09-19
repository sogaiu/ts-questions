#!/usr/bin/env bash

repos_root=../..

dir=$(pwd)

log_file="${dir}/log.txt"
ignored_symbols=(
    # gcc/clang specific, wasm uses something else
    "_Unwind_Resume"
    "_ZdlPv"
    "_Znwm"
    "_abort"
    "__cxa_atexit"
    "__cxa_begin_catch"
    "__cxa_end_catch"
    "__cxa_rethrow"
    "__gxx_personality_v0"
    "__stack_chk_fail"

    # what tree-sitter already exports
    "calloc"
    "free"
    "malloc"
    "realloc"

    "isalpha"
    "iswalnum"
    "iswalpha"
    "iswdigit"
    "iswlower"
    "iswspace"
    "memchr"
    "memcmp"
    "memcpy"
    "memmove"
    "memset"
    "strlen"
    "strcmp"
    "strncpy"
    "towupper"

    # symbols that don't seem to matter

    "__assert_fail"
    "__ctype_b_loc"

    # Svelte
    "abs"
    "atoi"
    "strncmp"

    "_ZSt17__throw_bad_allocv"
    "_ZSt20__throw_length_errorPKc"
    "_ZSt28__throw_bad_array_new_lengthv"
    "_ZSt9terminatev"

    "_ZSt21ios_base_library_initv"
)

for r in "${repos_root}"/repos/tree-sitter-*; do
    if [ -d "${r}" ]; then
        printf "Processing: %s\n" "${r}"
        cd "${r}" || exit 1
        file_c=src/scanner.c
        file_cc=src/scanner.cc
        if [[ -f "${file_c}" || -f "${file_cc}" ]]; then
            if [[ -f "${file_c}" ]]; then
                echo "Found scanner.c"
                scanner=c
            elif [[ -f "${file_cc}" ]]; then
                echo "Found scanner.cc"
                scanner=cc
            else
                echo "Error: neither scanner.c nor scanner.cc found"
                exit 1
            fi
            lang=$(basename "${r}" | \
                   sed -n 's#tree-sitter-\([^.]\+\)\..*#\1#p' | \
                   tr '-' '_')
            printf "Checking %s' scanner's exports...\n" "${lang}"
            command="clang -c -o scanner.o src/scanner.${scanner} -Wno-implicit-function-declaration"
            if ! ${command}; then
                printf "Command failed: %s\n" "${command}"
                exit 1
            fi
            functions=$(nm -u -- scanner.o | \
                        awk '{print $2}' | sort | uniq | \
                        grep -v -E "($(IFS="|"
                                       echo "${ignored_symbols[*]}"
                                      ))")
            if [[ -z "${functions// /}" ]]; then
                printf "No functions found\n"
            else
                printf "%s\n" "$(basename "${r}")" >> "${log_file}"
                printf "%s\n\n" "${functions}" >> "${log_file}"
            fi
            cd "${dir}" || exit 1
        fi

        # Look for nested scanner.c/cc files
        while IFS= read -r -d '' nested_file; do
            if [ -e "$nested_file" ]; then
                scanner_dir=$(dirname "$nested_file")
                cd "$scanner_dir/.." || exit 1

                scanner=$(echo "$nested_file" | \
                          grep -q ".cc" && \
                          echo "cpp" || echo "c")

                lang=$(grep -Eo "name:\s*['\"]([^'\"]+)['\"]" grammar.js | \
                       awk -F"['\"]" '{print $2}' | \
                       tr -d '\n')
                printf "Checking %s' scanner's exports...\n" "${lang}"
                command="clang -c -o scanner.o src/scanner.${scanner}"
                if ! ${command}; then
                    printf "Command failed: %s\n" "${command}"
                    exit 1
                fi
                functions=$(nm -u -- scanner.o | \
                            awk '{print $2}' | sort | uniq | \
                            grep -v -E "($(IFS="|"
                                           echo "${ignored_symbols[*]}"
                                          ))")
                if [[ -z "${functions// /}" ]]; then
                    printf "No functions found\n"
                else
                    printf "%s\n" "$(basename "${r}")" >> "${log_file}"
                    printf "%s\n\n" "${functions}" >> "${log_file}"
                fi
                cd "${dir}" || exit 1
            fi
        done < <(find . -name scanner.c -print0 -o -name scanner.cc -print0)
    fi
done
