#!/bin/bash
# One-time post-install reminder. The ~266 MB reference database is NOT bundled
# with the package (it is downloaded separately), so tell the user the next step
# right after `conda install`. Conda prints $PREFIX/.messages.txt after the
# transaction. Shown once, at install time.
cat >> "${PREFIX}/.messages.txt" <<'MSG'

============================================================
  Plastanno installed successfully.

  One more step before your first annotation — download the
  reference database (~266 MB, only needed once):

      conda activate plastanno
      plastanno fetch-db

============================================================
MSG
