#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=scripts/bioconda-utils-versions.sh
source "$(dirname "${BASH_SOURCE[0]}")/bioconda-utils-versions.sh"
utils_dir="$PWD/bioconda-utils"

checkout_utils() {
    git init --quiet "$utils_dir"
    # The release tag supplies the version for setuptools-scm.
    git -C "$utils_dir" fetch --depth 1 https://github.com/bioconda/bioconda-utils.git \
        "$BIOCONDA_UTILS_REVISION" "refs/tags/$BIOCONDA_UTILS_TAG:refs/tags/$BIOCONDA_UTILS_TAG"
    git -C "$utils_dir" checkout --quiet --detach "$BIOCONDA_UTILS_REVISION"
}

# CircleCI and Azure install Pixi here. GitHub Actions uses setup-pixi.
install_pixi() {
    installer=$(mktemp)
    trap 'rm -f "$installer"' EXIT
    curl -fsSL "https://github.com/prefix-dev/pixi/releases/download/$BIOCONDA_PIXI_VERSION/install.sh" -o "$installer"
    PIXI_VERSION="$BIOCONDA_PIXI_VERSION" PIXI_HOME="$PWD/.ci-pixi" PIXI_NO_PATH_UPDATE=1 bash "$installer"
}

configure_utils() {
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
