#! /bin/sh

# execute this from parent directory

dir=$(pwd)

for r in repos/tree-sitter-*
do
  cd "${r}" || exit 1
  git pull
  cd "${dir}" || exit 1
done
