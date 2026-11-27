#!/bin/bash
cat >> "${PREFIX}/.messages.txt" <<EOF

ted-merizo needs the Merizo network weights, which are not included in the package.
Download them once into the directory ted-merizo reads by default:

    mkdir -p ${PREFIX}/share/ted-merizo/weights
    cd ${PREFIX}/share/ted-merizo/weights
    for i in 0 1 2; do
        curl -fLO https://github.com/psipred/Merizo/raw/fa0c0baab010d65ac2d0e235412ebbfe46355c5f/weights/weights_part_\${i}.pt
    done

You can also download the weights into any directory and either
export MERIZO_WEIGHTS=<dir> or pass --weights_dir <dir> to ted-merizo.

EOF
