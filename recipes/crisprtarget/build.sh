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

# Upstream runs the scripts as `perl <script>` and `sh <script>` (one script
# hardcodes #!/usr/bin/perl); give all of them a working interpreter so that
# they can be called directly from PATH. The existing shebang has to be removed
# in a separate pass, `d` ends the sed cycle and would drop the inserted line.
for f in ./*.pl; do
    sed -i '1{/^#!/d}' "${f}"
    sed -i '1i #!/usr/bin/env perl' "${f}"
done
for f in ./*.sh; do
    sed -i '1{/^#!/d}' "${f}"
    sed -i '1i #!/usr/bin/env bash' "${f}"
done

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

chmod 0755 "${PREFIX}"/bin/CRISPRTarget*.pl \
           "${PREFIX}"/bin/CT*.pl \
           "${PREFIX}"/bin/PAMRescore.pl \
           "${PREFIX}"/bin/TargetPredict.pl \
           "${PREFIX}"/bin/MakeUser*.sh
