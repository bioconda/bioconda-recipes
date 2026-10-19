#!/bin/bash

set -e
set -u
set -x
set -o pipefail

which hictk
if [[ "${OSTYPE}" =~ .*darwin.* ]]; then
  otool -L "$(which hictk)"
else
  ldd "$(which hictk)"
fi

hictk --version

"${RECIPE_DIR}/download_test_dataset.sh"

# Try to install the test suite
if ! pip install test/integration --only-binary=hictkpy; then
  1>&2 echo "WARNING! Unable to install hictk's integration suite (see messages above for the reason)"
  1>&2 echo "WARNING! Only running a simple test for hictk convert!"
  hictk convert test/data/cooler/4DNFIZ1ZVXC8.mcool out.hic
  1>&2 echo "WARNING! Unable to install hictk's integration suite (see messages above for the reason)"
  exit 0
fi

# Run integration tests
hictk_integration_suite \
  "$(which hictk)" \
  test/integration/config.toml \
  --data-dir test/data \
  --do-not-copy-binary \
  --threads "${CPU_COUNT}" \
  --result-file results.json

printf '#####\n#####\n#####\n\n\n'
cat results.json
