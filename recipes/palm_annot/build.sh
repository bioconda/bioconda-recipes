#!/bin/bash
set -euo pipefail

DATA_DIR="${PREFIX}/share/${PKG_NAME}"
mkdir -p "${PREFIX}/bin" "${DATA_DIR}"

# Install all Python sources and data files into a single tree under
# $PREFIX/share/palm_annot/. palm_annot.py references files relative to
# its own dirname/.. so this preserves that layout.
cp -r py "${DATA_DIR}/"
for d in bash hmmdbs motif_hmms motif_stos pssms rdrp_plus_hmms rdrp_minus_hmms diamond_refdbs; do
  if [[ -d "$d" ]]; then
    cp -r "$d" "${DATA_DIR}/"
  fi
done
chmod -R u+w "${DATA_DIR}"
find "${DATA_DIR}/py" -name '*.py' -exec chmod 0755 {} +

# Patch palm_annot.py so:
#   1. RepoDir is pinned to DATA_DIR (and respects PALM_ANNOT_DIR override,
#      matching the convention already used by the helper scripts).
#   2. palmscan2 is invoked from PATH instead of "${RepoDir}/bin/palmscan2",
#      because the binary now ships in the separate palmscan conda package.
python - "${DATA_DIR}/py/palm_annot.py" "${DATA_DIR}/" <<'PY'
import io, sys, pathlib
script, data_dir = sys.argv[1], sys.argv[2]
p = pathlib.Path(script)
text = p.read_text()
old = 'RepoDir = os.path.dirname(os.path.realpath(__file__ + "/..")) + "/"\nassert os.path.isdir(RepoDir)\n'
new = (
    'RepoDir = os.environ.get("PALM_ANNOT_DIR", "%s")\n'
    'if not RepoDir.endswith("/"):\n'
    '\tRepoDir += "/"\n'
    'assert os.path.isdir(RepoDir)\n'
) % data_dir
if old not in text:
    sys.exit("RepoDir block not found in palm_annot.py; recipe needs update")
text = text.replace(old, new)
text = text.replace('RepoDir + "bin/palmscan2"', '"palmscan2"')
p.write_text(text)
PY

# Expose user-facing CLIs in $PREFIX/bin via symlinks.
for s in palm_annot.py fev2tsv.py \
         palm_annot_fasta_select_intact_pp.py \
         palm_annot_fasta_trim_intact_palmcore.py; do
  ln -sf "${DATA_DIR}/py/${s}" "${PREFIX}/bin/${s}"
done
