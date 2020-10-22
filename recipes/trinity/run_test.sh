#!/bin/sh

set -x -e

${CONDA_PREFIX}/opt/trinity-*/Inchworm/bin/inchworm --help &>/dev/null || [ $? -eq 1 ]
${CONDA_PREFIX}/opt/trinity-*/Chrysalis/bin/Chrysalis --help &>/dev/null || [ $? -eq 255 ]
${CONDA_PREFIX}/opt/trinity-*/Chrysalis/bin/QuantifyGraph --help &>/dev/null || [ $? -eq 255 ]
${CONDA_PREFIX}/opt/trinity-*/Chrysalis/bin/ReadsToTranscripts --help &>/dev/null || [ $? -eq 255 ]
${CONDA_PREFIX}/opt/trinity-*/trinity-plugins/BIN/ParaFly --help &>/dev/null || [ $? -eq 1 ]
