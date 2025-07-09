#!/bin/bash

mkdir -p "${PREFIX}/bin"

if [[ "$(uname -m)" == "aarch64" || "$(uname -m)" == "arm64" ]]; then
	sed -i.bak 's|--passC:"-mpopcnt"||' nim.cfg
	rm -rf *.bak
fi

nimble --localdeps build -y --verbose -d:release

install -v -m 0755 somalier "${PREFIX}/bin"
