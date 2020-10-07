#!/usr/bin/env bash

mkdir -p "${PREFIX}"/bin
cp juliet cleric fuse mixdata julietflow "${PREFIX}"/bin/
chmod +x "${PREFIX}"/bin/{juliet,cleric,fuse,mixdata,julietflow}
