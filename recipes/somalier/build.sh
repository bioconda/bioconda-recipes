#!/bin/bash

mkdir -p "${PREFIX}/bin"

case $(uname -m) in
    aarch64)
	sed -i.bak 's|--passC:"-mpopcnt"||' nim.cfg
  rm -rf *.bak
	;;
    arm64)
	sed -i.bak 's|--passC:"-mpopcnt"||' nim.cfg
  rm -rf *.bak
	;;
esac

nimble --localdeps build -y --verbose -d:release

install -v -m 0755 somalier "${PREFIX}/bin"
