#! /bin/sh

# execute this from parent directory

stats=$(sh ./script/list-parser-c-abi-nums.sh)
nums=$(echo "${stats}" | cut -d' ' -f1 | sort -n | uniq)

n_repos=$(echo "${stats}" | wc -l)

printf "ABI: Count\n\n"

for n in ${nums}
do
    count=$(echo "${stats}" | grep -c "${n}")
    printf "%d: %d\n" "${n}" "${count}"
done

printf "\n"

printf "Minimum number of repositories with parser.c: %d\n" "${n_repos}"

