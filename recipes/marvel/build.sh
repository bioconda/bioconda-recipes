#!/bin/bash
set -exo pipefail
 
mkdir -p ${PREFIX}/bin ${PREFIX}/marvel_db/

chmod +x marvel download_and_set_models.py marvel_prokka
mv marvel download_and_set_models.py marvel_prokka ${PREFIX}/bin/
${PREFIX}/bin/download_and_set_models.py ${PREFIX}/marvel_db/
