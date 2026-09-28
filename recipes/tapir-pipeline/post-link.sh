#!/bin/bash
# Install pip-only dependencies not available in bioconda/conda-forge
"${PREFIX}/bin/pip" install viralquest 2>&1 || true
