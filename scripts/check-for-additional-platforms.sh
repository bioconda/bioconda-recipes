#!/bin/bash

# This lightweight preflight avoids allocating scarce macOS ARM capacity for
# changes that do not opt into the platform. Build eligibility itself remains
# enforced by bioconda-utils.

git_range=$1
job_name=$2
current_job=$3

yq_platform=$(uname)
yq_arch=$(uname -m)
[[ ${yq_arch} = "aarch64" ]] && yq_arch="arm64"
yq_path="${HOME}/bin/yq"
mkdir -p "${HOME}/bin"
wget "https://github.com/mikefarah/yq/releases/latest/download/yq_${yq_platform}_${yq_arch}" -O "${yq_path}"
chmod +x "${yq_path}"

files=$(git diff --name-only --diff-filter AMR "${git_range}" | grep -E 'meta.yaml$' || true)
build=0

for file in ${files}; do
    # Produce YAML that yq can inspect by commenting out Jinja statements and
    # removing Jinja expression delimiters.
    additional_platforms=$(sed -E 's/(.*)\{%(.*)%\}(.*)/# \1\2\3/g' "${file}" |
        tr -d '{{' |
        tr -d '}}' |
        "${yq_path}" '.extra.additional-platforms[]')
    parsing_status=$?
    if [[ ${parsing_status} -gt 0 ]]; then
        echo "Unable to inspect additional platforms in ${file}" >&2
        exit "${parsing_status}"
    fi

    for additional_platform in ${additional_platforms}; do
        if [[ ${current_job} = "${job_name}-${additional_platform}" ]]; then
            build=1
            break
        fi
    done
done

if [[ ${build} -gt 0 ]]; then
    echo "build"
fi
