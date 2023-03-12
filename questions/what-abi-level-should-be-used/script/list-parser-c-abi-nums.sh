#! /bin/sh

dir=$(pwd)

repos_root=../..

for r in "${repos_root}"/repos/tree-sitter-*
do
  cd "${r}" || exit
  if [ -e src/parser.c ]; then
    grep -a define\ LANGUAGE_VERSION src/parser.c | cut -d' ' -f3 | tr -d '\n'
    printf " %s\n" "$(basename "${r}")"
  fi
  cd "${dir}" || exit
done
