#! /bin/sh

# execute this from parent directory

repos_root=../..

dir=$(pwd)

n_repos=0
n_scanner=0

for r in "${repos_root}"/repos/tree-sitter-*
do
    cd "${r}" || exit 1
    n_repos=$((n_repos + 1))
    # XXX: not quite right in all cases?
    for file in src/scanner.*
    do
        if [ -e "$file" ]; then
            printf "%s: %s\n" "$(basename "${r}")" "$(basename "${file}")"
            n_scanner=$((n_scanner + 1))
            break
        fi
    done
    cd "${dir}" || exit 1
done

printf "\n"

printf "Minimum number of repositories with scanner.*: %d\n" "${n_scanner}"
printf "Number of repositories: %d\n" "${n_repos}"

