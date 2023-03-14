#! /bin/sh

# execute this from parent directory

repos_root=../..

dir=$(pwd)

n_repos=0

n_scanner_c=0
for r in "${repos_root}"/repos/tree-sitter-*
do
    cd "${r}" || exit 1
    n_repos=$((n_repos + 1))
    file=src/scanner.c
    if [ -e "$file" ]; then
        printf "%s/%s\n" "$(basename "${r}")" "${file}"
        n_scanner_c=$((n_scanner_c + 1))
    fi
    for file in */src/scanner.c
    do
        if [ -e "$file" ]; then
            printf "%s/%s\n" "$(basename "${r}")" "${file}"
            n_scanner_c=$((n_scanner_c + 1))
        fi
    done
    cd "${dir}" || exit 1
done

# separate the two lists
printf "\n"

n_scanner_cc=0
for r in "${repos_root}"/repos/tree-sitter-*
do
    cd "${r}" || exit 1
    file=src/scanner.cc
    if [ -e "$file" ]; then
        printf "%s/%s\n" "$(basename "${r}")" "${file}"
        n_scanner_cc=$((n_scanner_cc + 1))
    fi
    for file in */src/scanner.cc
    do
        if [ -e "$file" ]; then
            printf "%s/%s\n" "$(basename "${r}")" "${file}"                
            n_scanner_cc=$((n_scanner_cc + 1))
        fi
    done
    cd "${dir}" || exit 1
done

printf "\n"

printf "Minimum number of repositories with scanner.c: %d\n" "${n_scanner_c}"
printf "Minimum number of repositories with scanner.cc: %d\n" "${n_scanner_cc}"
printf "Number of repositories: %d\n" "${n_repos}"

