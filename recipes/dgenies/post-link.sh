#!/bin/bash

sed -i.bak \
  -e '/^minimap2:/ {
    N
    N
    s|^\(minimap2:\n  exec: \)default\(\n  label:\).*$|\1 minimap2\2 "Minimap2"|
  }' \
  -e '/^mashmap:/ {
    N
    s|^\(mashmap:\n  exec: \)default|\1 mashmap|
  }' \
  ${PREFIX}/lib/python*/site-packages/etc/dgenies/tools.yaml
