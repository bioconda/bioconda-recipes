#!/bin/bash
# Install pip-only dependencies not available in bioconda/conda-forge
"${PREFIX}/bin/pip" install --no-deps viralquest 2>&1 || true
