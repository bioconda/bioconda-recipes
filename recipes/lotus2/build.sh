#!/bin/sh
SHARE_DIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p "$SHARE_DIR"
cp -R "$SRC_DIR"/* "$SHARE_DIR/"
cd "$SHARE_DIR/"
rm -rf bin/installs/ bin/LCA bin/rtk bin/sdm configs/sdm_src/
# Configure LotuS2
cp configs/LotuS.cfg.def lOTUs.cfg
for binary in blastn clustalo lambda LCA mafft minimap2 rtk sdm swarm vsearch; do
    sed -i -e "s|^$binary[[:space:]].*|$binary $PREFIX/bin/$binary|" lOTUs.cfg
done
for binary in cd-hit fasttree hmmsearch iqtree itsx lambda_index makeBlastDB; do
    sed -i -e "s|^$binary[[:space:]]\(.*\)|$binary $PREFIX/bin/\1|" lOTUs.cfg
done
sed -i -e "s|^RDPjar[[:space:]].*|RDPjar $PREFIX/share/rdp_classifier/rdp_classifier.jar|" lOTUs.cfg

# install LotuS2 wrapper
mkdir -p "${PREFIX}/bin"
sed -e "s|CHANGEME|${SHARE_DIR}|" "$RECIPE_DIR/lotus2.sh" > "${PREFIX}/bin/lotus2"
