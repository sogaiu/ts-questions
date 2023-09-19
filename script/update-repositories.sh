#! /bin/sh

# execute this from parent directory

dir=$(pwd)

for r in repos/tree-sitter-*
do
  cd "${r}" || exit 1
  printf "%s\n" "${r}"
  git pull
  cd "${dir}" || exit 1
done
