#!/bin/bash

set -x


# Check to see if any changed recipes have specified the key
# extra:additional-platforms, and if so, if they match the platform of the
# currently-running machine.

# arguments
git_range=$1
job_name=$2

# Download ARM version of yq
yq_platform=$(uname)
yq_arch=$(uname -m)
[[ $yq_arch = "aarch64" ]] && yq_arch="arm64"
wget https://github.com/mikefarah/yq/releases/latest/download/yq_${yq_platform}_${yq_arch} -q -O yq
chmod +x ./yq


# Find recipes changed from this merge
files=`git diff --name-only --diff-filter AMR ${git_range} | grep -E 'meta.yaml$' `
build=0

for file in $files; do
    echo $file
    # To create a properly-formatted yaml that yq can parse, comment out jinja2
    # variable setting with {% %} and remove variable use with {{ }}.
    additional_platforms=$(cat $file \
    | sed -E 's/(.*)\{%(.*)%\}(.*)/# \1\2\3/g' \
    | sed -E 's/(.*)\{\{(.*)\}\}(.*)/\1\2\3/g' \
    | ./yq '.extra.additional-platforms[]')
    # Check if any additional platforms match this job
    for additional_platform in $additional_platforms; do
    if [ "${CIRCLE_JOB}" = "${job_name}-${additional_platform}" ]
    then
        build=1
        break
    fi
    done
done

# If no changed recipes apply to this platform, skip remaining steps
if [[ build -lt 1 ]]
then
    echo "No recipes using this platform, skipping rest of job."
    circleci-agent step halt
fi
