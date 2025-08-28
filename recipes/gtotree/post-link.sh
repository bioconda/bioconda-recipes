printf "will cite" | parallel --citation 2&> /dev/null

# removing coreutils ls so the user-system one is used still
rm ${CONDA_PREFIX}/bin/ls
