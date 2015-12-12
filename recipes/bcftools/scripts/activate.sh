#!/bin/bash
if [[ -z "$PWD/plugins" ]]; then
	export BCFTOOLS_PLUGINS=$(pwd)/plugins
	export _CONDA_SET_BCFTOOLS_PLUGINS=1
fi
