#!/bin/bash

python -m pip install . --no-deps --ignore-installed -vv

if [[ $(uname -s -m) != "Linux x86_64" ]]; then
sed -i'' \
  -e '/^minimap2:/ {
    N
    N
    s|^\(minimap2:\n  exec: \)default\(\n  label:\).*$|\1 minimap2\2 "Minimap2"|
  }' \
  -e '/^mashmap:/ {
    N
    s|^\(mashmap:\n  exec: \)default|\1 mashmap|
  }' \
  ${SP}/etc/dgenies/tools.yaml
fi
