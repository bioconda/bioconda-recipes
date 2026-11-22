#!/usr/bin/env bash
# Source from a CI step to run commands in the pinned environment.
export PATH="$PWD/.ci-pixi/bin:$PATH"
export PIXI_PROJECT_MANIFEST="$PWD/bioconda-utils/pixi.toml"
bioconda_pixi_hook=$(pixi shell-hook --locked --shell bash) || return
eval "$bioconda_pixi_hook"
unset bioconda_pixi_hook
