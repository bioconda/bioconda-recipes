#!/bin/bash
set -euo pipefail

nemo="nemo${PKG_VERSION}"
command -v "$nemo" >/dev/null || { echo "ERROR: $nemo not on PATH" >&2; exit 1; }

# The banner carries the version; this is the check the Bioconda recipe had.
# Run without arguments nemo looks for a Nemo2.ini it will not find, so ignore
# its exit status and assert on the banner text instead.
banner="$("$nemo" 2>&1 || true)"
printf '%s\n' "$banner" | grep -F "${PKG_VERSION}" >/dev/null || {
    echo "ERROR: version ${PKG_VERSION} absent from the startup banner:" >&2
    printf '%s\n' "$banner" >&2
    exit 1
}

# Run the simulation. Nemo returns 0 on success and writes <root_dir>/<filename>.txt;
# locate it rather than hard-coding, so a change in naming shows up as a clear
# failure here instead of a false pass.
"$nemo" smoke.ini

stats="$(find smoke-out -name '*.txt' -type f 2>/dev/null | head -n1 || true)"
if [ -z "$stats" ]; then
    echo "ERROR: no stats file produced under smoke-out/" >&2
    ls -R . >&2
    exit 1
fi
echo "stats file: $stats"
cat "$stats"

# The real check: additive genetic variance must be non-zero. An all-zero column
# means mutation or the stat machinery did not actually run, which a binary that
# starts up and exits 0 will not otherwise tell us.
awk '
  NR == 1 {
      for (i = 1; i <= NF; i++) if ($i ~ /\.Va$/) va[i] = $i
      if (length(va) == 0) {
          print "ERROR: no .Va column in stats header:" > "/dev/stderr"
          print $0 > "/dev/stderr"
          exit 1
      }
      next
  }
  { for (i in va) if ($i + 0 != 0) found = 1 }
  END {
      if (!found) {
          print "ERROR: every .Va value is zero -- no genetic variance accumulated," > "/dev/stderr"
          print "       so mutation or the quanti stat machinery did not run" > "/dev/stderr"
          exit 1
      }
      print "OK: non-zero additive genetic variance recorded"
  }
' "$stats"
