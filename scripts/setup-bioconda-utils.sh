#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=scripts/bioconda-utils-versions.sh
source "$(dirname "${BASH_SOURCE[0]}")/bioconda-utils-versions.sh"
utils_dir="$PWD/bioconda-utils"

checkout_utils() {
    local tag=${BIOCONDA_UTILS_TAG:?BIOCONDA_UTILS_TAG must be set}
    local revision=${BIOCONDA_UTILS_REVISION:-}
    local url=https://github.com/bioconda/bioconda-utils.git

    git init --quiet "$utils_dir"

    # Fetch the tag explicitly: a depth-1 fetch of a SHA does not include tag
    # refs, and setuptools-scm needs the tag to derive the version.
    git -C "$utils_dir" fetch --depth 1 "$url" \
        "refs/tags/$tag:refs/tags/$tag"

    if [[ -n $revision ]]; then
        # Test an unreleased commit or branch instead of the release tag.
        git -C "$utils_dir" fetch --depth 1 "$url" \
            "$revision:refs/bioconda-utils/revision"
        git -C "$utils_dir" checkout --quiet --detach refs/bioconda-utils/revision
    else
        git -C "$utils_dir" checkout --quiet --detach "refs/tags/$tag"
    fi
}

# CircleCI and Azure install Pixi here. GitHub Actions uses setup-pixi.
install_pixi() {
    installer=$(mktemp)
    trap 'rm -f "$installer"' EXIT
    curl -fsSL "https://github.com/prefix-dev/pixi/releases/download/$BIOCONDA_PIXI_VERSION/install.sh" -o "$installer"
    PIXI_VERSION="$BIOCONDA_PIXI_VERSION" PIXI_HOME="$PWD/.ci-pixi" PIXI_NO_PATH_UPDATE=1 bash "$installer"
}

configure_utils() {
    local tag=${BIOCONDA_UTILS_TAG:?BIOCONDA_UTILS_TAG must be set}
    local revision=${BIOCONDA_UTILS_REVISION:-}

    if [[ -n $revision ]]; then
        local head_sha tag_commit
        head_sha=$(git -C "$utils_dir" rev-parse HEAD)
        tag_commit=$(git -C "$utils_dir" rev-parse "refs/tags/$tag^{commit}")
        if [[ $head_sha != "$tag_commit" ]]; then
            # The shallow clone has no history linking the revision to the
            # tag, so setuptools-scm cannot derive a version itself. Keep the
            # X.Y.Z prefix that extract_stable_version() needs for the build
            # image lookup.
            export SETUPTOOLS_SCM_PRETEND_VERSION_FOR_BIOCONDA_UTILS="${tag#v}.post0.dev0+${head_sha:0:7}"
        fi
    fi

    export PIXI_PROJECT_MANIFEST="$utils_dir/pixi.toml"
    pixi run --locked -e default install
    pixi run --locked conda config --set always_yes yes
    pixi run --locked conda config --add channels bioconda
    pixi run --locked conda config --add channels conda-forge
    pixi run --locked conda config --set channel_priority strict
    pixi run --locked conda config --set conda_build.pkg_format 2

    if [[ ${BIOCONDA_DISABLE_BUILD_PREP:-0} == 0 ]]; then
        conda_bld=$(pixi run --locked python -c 'from conda_build.config import Config; print(Config().croot)')
        pixi run --locked conda config --add channels "file://${conda_bld}"
    fi
}

case "${1:-all}" in
    checkout) checkout_utils ;;
    configure) configure_utils ;;
    all)
        checkout_utils
        install_pixi
        export PATH="$PWD/.ci-pixi/bin:$PATH"
        configure_utils
        ;;
    *)
        echo "Usage: $0 [checkout|configure|all]" >&2
        exit 2
        ;;
esac
