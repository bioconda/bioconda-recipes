#!/bin/sh

set -x -e

${CONDA_PREFIX}/opt/trinity-*/Inchworm/bin/inchworm --help &>/dev/null || [ $? -eq 1 ]
${CONDA_PREFIX}/opt/trinity-*/Chrysalis/Chrysalis --help &>/dev/null || [ $? -eq 255 ]
${CONDA_PREFIX}/opt/trinity-*/Chrysalis/QuantifyGraph --help &>/dev/null || [ $? -eq 255 ]
${CONDA_PREFIX}/opt/trinity-*/Chrysalis/ReadsToTranscripts --help &>/dev/null || [ $? -eq 255 ]
${CONDA_PREFIX}/bin/ParaFly --help &>/dev/null || [ $? -eq 1 ]
