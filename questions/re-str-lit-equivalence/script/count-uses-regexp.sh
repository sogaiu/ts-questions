#! /bin/sh

# execute this from parent directory

repos_root=../..

users=$(grep -l RegExp "${repos_root}"/repos/tree-sitter*/grammar.js | wc -l)
# shellcheck disable=SC2012
n_repos=$(ls -ald "${repos_root}"/repos/* | wc -l)

printf "Number of repositories using RegExp: %d\n" "${users}"
printf "Number of repositories: %d\n" "${n_repos}"
