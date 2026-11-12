#!/bin/bash
set -ex

${PYTHON} setup.py config -c
${PYTHON} setup.py upp -c

# ensure SEPP's configuration file is at the correct location ...
echo "${PREFIX}/share/sepp/sepp" > home.path
mkdir -p $PREFIX/share/sepp/sepp
# ... and holds correct path names
cp -v sepp-package/sepp/default.main.config $PREFIX/share/sepp/sepp/main.config
# copy upp config, as it's still needed
cp -f ./.sepp/upp.config $PREFIX/share/sepp/sepp/upp.config

${PYTHON} -m pip install . --no-build-isolation --no-deps --no-cache-dir -vvv

# ensure directory is created ... ($SP_DIR = Python's site-packages location, see https://docs.conda.io/projects/conda-build/en/stable/user-guide/environment-variables.html#environment-variables-set-during-the-build-process)
mkdir -p $SP_DIR/
# ... before we copy content into it
cp -rfv home.path $SP_DIR/

# recompile PPlacerJSONMerger.java (for pplacer >=1.1.alpha17 .jplace field order) and install seppJsonMerger.jar into $PREFIX/share/sepp/sepp/
mkdir -p build_merger
javac --release 8 -cp "$SRC_DIR/tools/merge/seppJsonMerger.jar" -d build_merger "$SRC_DIR/tools/merge/src/phylolab/taxonamic/PPlacerJSONMerger.java"
${PYTHON} - <<'EOF'
import os, zipfile
src_jar = os.path.join(os.environ["SRC_DIR"], "tools/merge/seppJsonMerger.jar")
dst_jar = os.path.join(os.environ["PREFIX"], "share/sepp/sepp/seppJsonMerger.jar")
replacements = {}
for root, _, files in os.walk("build_merger"):
    for f in files:
        rel = os.path.relpath(os.path.join(root, f), "build_merger")
        replacements[rel] = os.path.join(root, f)
seen = set()
with zipfile.ZipFile(src_jar, "r") as zin, zipfile.ZipFile(dst_jar, "w", zipfile.ZIP_DEFLATED) as zout:
    for item in zin.infolist():
        if item.filename in seen:
            continue
        seen.add(item.filename)
        if item.filename in replacements:
            with open(replacements[item.filename], "rb") as rf:
                zout.writestr(item, rf.read())
        else:
            zout.writestr(item, zin.read(item.filename))
EOF

# configure run-sepp.sh for qiime2 fragment-insertion
mkdir -p $PREFIX/bin/
cp -v sepp-package/run-sepp.sh $PREFIX/bin/run-sepp.sh

# copy files for tests to shared conda directory
mkdir -p $PREFIX/share/sepp/ref/
cp -vf test/unittest/data/q2-fragment-insertion/input_fragments.fasta $PREFIX/share/sepp/ref/
cp -vf test/unittest/data/q2-fragment-insertion/reference_alignment_tiny.fasta $PREFIX/share/sepp/ref/
cp -vf test/unittest/data/q2-fragment-insertion/reference_phylogeny_tiny.nwk $PREFIX/share/sepp/ref/
cp -vf test/unittest/data/q2-fragment-insertion/RAxML_info-reference-gg-raxml-bl.info $PREFIX/share/sepp/ref/
