#!/bin/sh

set -x -e

${CONDA_PREFIX}/bin/Inchworm/bin/inchworm --help &>/dev/null || [ $? -eq 1 ]
${CONDA_PREFIX}/bin/Chrysalis/bin/Chrysalis --help &>/dev/null || [ $? -eq 255 ]
${CONDA_PREFIX}/bin/Chrysalis/bin/QuantifyGraph --help &>/dev/null || [ $? -eq 255 ]
${CONDA_PREFIX}/bin/Chrysalis/bin/ReadsToTranscripts --help &>/dev/null || [ $? -eq 255 ]
${CONDA_PREFIX}/bin/trinity-plugins/BIN/ParaFly --help &>/dev/null || [ $? -eq 1 ]
