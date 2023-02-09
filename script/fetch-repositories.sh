#! /bin/sh

# execute this from parent directory

first_cwd=$(pwd)

mkdir -p repos
cd repos || exit 1

while IFS= read -r line
do
    #printf "line: %s\n" "${line}"
    repo_name=$(echo "${line}" | sed -e 's#\(.*\)/\(tree-sitter-.*\)#\2#')
    user_name=$(echo "${line}" | sed -e 's#\(.*\)/\(.*\)/tree-sitter-.*#\2#')
    #printf "repo_name: %s\n" "${repo_name}"
    #printf "user_name: %s\n" "${user_name}"
    dir_name="${repo_name}.${user_name}"
    if [ ! -e "${dir_name}" ]; then
        printf "cloning %s to %s\n" "${repo_name}" "${dir_name}"
        git clone "${line}" "${dir_name}"
    fi
done < ../ts-grammar-repositories.txt

cd "${first_cwd}" || exit 1
