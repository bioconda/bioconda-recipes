#!/bin/bash

python -m pip install . --no-deps --ignore-installed -vv

if [[ $(uname -s -m) != "Linux x86_64" ]]; then
    sed -i'' -e 's/label: "Minimap2.*"/label: "Minimap2"/' ${SP}/etc/dgenies/tools.yaml
fi
