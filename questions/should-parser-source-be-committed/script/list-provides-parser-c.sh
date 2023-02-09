#! /bin/sh

# execute this from parent directory

dir=$(pwd)

repos_root=../..

n_repos=0
n_parser_c=0

for r in "${repos_root}"/repos/tree-sitter-*
do
    cd "${r}" || exit 1
    n_repos=$((n_repos + 1))
    # XXX: not quite right in all cases (e.g. typescript)
    if [ -e src/parser.c ]; then
        printf "%s\n" "$(basename ${r})"
        n_parser_c=$((n_parser_c + 1))
    fi
    cd "${dir}" || exit 1
done

printf "\n"

printf "Minimum number of repositories with parser.c: %d\n" "${n_parser_c}"
printf "Number of repositories: %d\n" "${n_repos}"

