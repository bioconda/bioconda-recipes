#!/bin/bash
set -euo pipefail

mkdir -p "${PREFIX}/bin"

# Upstream bundles prebuilt binaries (bedtools, blast+, samtools, easel) in bin/
# and calls them as $cd_path/bin/<tool> or $SCRIPTPATH/bin/<tool>. Use the
# Bioconda packages from PATH instead and drop the bundled binaries.
sed -i -e 's|\$cd_path/bin/||g' -e 's|\$SCRIPTPATH/bin/||g' ./*.pl ./*.sh

# Databases and indices created at runtime default to directories next to the
# scripts (i.e. inside the conda prefix). Point them to the working directory
# instead so that a (possibly read-only) prefix is never written to.
sed -i -e 's|\$cd_path/USER_SHUFFLED_DB|USER_SHUFFLED_DB|g' \
       -e 's|\$cd_path/USER_DB|USER_DB|g' \
       -e 's|\$cd_path/USER_SHUFFLE_DB/|USER_SHUFFLE_DB/|g' \
       -e 's|\$cd_path/DB/|DB/|g' \
       CRISPRTarget.pl

# Upstream scripts are run as `perl <script>` (no shebang) or `sh <script>`;
# make them directly executable.
sed -i '1i #!/usr/bin/env perl' CRISPRTarget.pl
sed -i '1i #!/usr/bin/env bash' MakeUserDB.sh MakeUserShuffledDB.sh

cp CRISPRTarget.pl \
   CRISPRTargetGraphics.pl \
   CRISPRTarget_cmd.pl \
   CTFlankExtract.pl \
   CTGFFInput.pl \
   CTProcessInput.pl \
   PAMRescore.pl \
   TargetPredict.pl \
   MakeUserDB.sh \
   MakeUserShuffledDB.sh \
   "${PREFIX}/bin/"

chmod 0755 "${PREFIX}/bin/CRISPRTarget.pl" \
           "${PREFIX}/bin/MakeUserDB.sh" \
           "${PREFIX}/bin/MakeUserShuffledDB.sh"
