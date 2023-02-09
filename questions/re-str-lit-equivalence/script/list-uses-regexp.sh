#! /bin/sh

# execute this from parent directory

repos_root=../..

dir=$(pwd)

n_repos=0
n_hits=0

for r in "${repos_root}"/repos/tree-sitter-*
do
    cd "${r}" || exit 1
    n_repos=$((n_repos + 1))
    # XXX: not quite right in all cases?
    file=grammar.js
    if [ -e "$file" ]; then
        grep -q RegExp "${file}"
        status=$?
        if [ 0 -eq "${status}" ]; then
            printf "%s\n" "$(basename "${r}")"
            n_hits=$((n_hits + 1))
        fi
    fi
    cd "${dir}" || exit 1
done

printf "\n"

printf "Minimum number of repositories using RegExp: %d\n" "${n_hits}"
printf "Number of repositories: %d\n" "${n_repos}"

