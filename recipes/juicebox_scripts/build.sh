#!/bin/bash -x

# -e = exit on first error
# -x = print every executed command
set -ex

mkdir -p ${PREFIX}/bin

install_script() {
    local script=$1

    sed -i.bak '1s|.*|#!/usr/bin/env python3|' juicebox_scripts/${script}
    
    mv juicebox_scripts/${script} ${PREFIX}/bin/${script}
    chmod a+x ${PREFIX}/bin/${script}
}

install_script makeAgpFromFasta.py
install_script juicebox_assembly_purger.py
install_script juicebox_assembly_converter.py
install_script degap_assembly.py
install_script agp2assembly.py