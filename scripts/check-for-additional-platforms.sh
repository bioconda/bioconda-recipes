#!/bin/bash

set -x

# Do not set -x, this script outputs a value with echo

# Check to see if any changed recipes have specified the key
# extra:additional-platforms, and if so, if they match the platform of the
# currently-running machine.

# arguments
git_range=$1
job_name=$2
current_job=$3

# Download ARM version of yq
yq_platform=$(uname)
yq_arch=$(uname -m)
[[ $yq_arch = "aarch64" ]] && yq_arch="arm64"
mkdir -p ${HOME}/bin
wget https://github.com/mikefarah/yq/releases/latest/download/yq_${yq_platform}_${yq_arch} -O ${HOME}/bin/yq
chmod +x ${HOME}/bin/yq

# Find recipes changed from this merge
files=`git diff --name-only --diff-filter AMR ${git_range} | grep -E 'meta.yaml$' `
build=0

for file in $files; do
    # To create a properly-formatted yaml that yq can parse, comment out jinja2
    # variable setting with {% %} and remove variable use with {{ }}.
    additional_platforms=$(cat $file \
    | sed -E 's/(.*)\{%(.*)%\}(.*)/# \1\2\3/g' \
    | tr -d '{{' | tr -d '}}' \
    | ${HOME}/bin/yq '.extra.additional-platforms[]')

    parsing_status=$?
    if [ $parsing_status -gt 0 ]; then
        echo "An error occurred while reading/parsing ${file}"
        echo "==================== ${file} START ==========================="
        cat $file
        echo "==================== ${file} END ============================="
        exit $parsing_status
    fi

    # Check if any additional platforms match this job
    for additional_platform in $additional_platforms; do
    if [ "${current_job}" = "${job_name}-${additional_platform}" ]
    then
        build=1
        break
    fi
    done
done

# If no changed recipes apply to this platform, skip remaining steps
if [[ build -gt 0 ]]
then
    echo "build"
fi
