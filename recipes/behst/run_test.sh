#!/bin/bash
set -euo pipefail

# download script dumps progress to stdout, causing too-large log output on
# travis. Dump to temp log and only report if it fails.
echo "[`date`] Downloading example data (log in /tmp/download.log)"
behst-download-data -d /tmp/behst --small &> /tmp/download.log || cat /tmp/download.log
echo "[`date`] finished downloading example data"

behst /tmp/behst/pressto_LUNG_enhancers.bed -d /tmp/behst
