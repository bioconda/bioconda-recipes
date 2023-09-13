#!/bin/bash

"${PYTHON}" -m pip install . --no-deps -vv

if [[ ${target_platform} =~ linux.* ]] ; then
  gunzip ORFfinder.gz
  chmod +x ORFfinder
  mv ORFfinder "${PREFIX}/bin/"
fi
