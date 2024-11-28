#! /usr/bin/env bash

export LC_ALL=en_US.UTF-8

# compile jars uising condaforge's gradle
gradle jvarkit


# setup directories
TGT="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"
[ -d "${TGT}" ] || mkdir -p "${TGT}"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

# jars
cp -p dist/*.jar "${TGT}"

# wrapper(s)
cp "${RECIPE_DIR}/${PKG_NAME}.sh" "${TGT}/${PKG_NAME}"
chmod 0755 "${TGT}/${PKG_NAME}"
# NOTE on older mac osx, use coreutils for realpath
ln -s "$(realpath --relative-to "${PREFIX}/bin" "${TGT}/${PKG_NAME}")" "${PREFIX}/bin/${PKG_NAME}"

# more wrapper
cp "${RECIPE_DIR}/dispatcher.sh" "${TGT}/dispatcher"
chmod 0755 "${TGT}/dispatcher"
#
# Parse the subcommand help table with awk:
# |                      Name | Description                                                                                            |
# |---------------------------+--------------------------------------------------------------------------------------------------------|
# |       addlinearindextobed | Use a Sequence dictionary to create a linear index for a BED file. Can be used as a X-Axis for a chart.|
# |                backlocate | Mapping a mutation on a protein back to the genome.                                                    |
# |            bam2haplotypes | Reconstruct SNP haplotypes from reads                                                                  |
# |                bam2raster | BAM to raster graphics                                                                                 |
# |                   bam2sql | Convert a SAM/BAM to sqlite statements                                                                 |
# |                   bam2svg | BAM to Scalar Vector Graphics (SVG)                                                                    |
# |                   bam2xml | converts a BAM to XML                                                                                  |
#  …
java -jar dist/jvarkit.jar --help | awk 'BEGIN{FS="|"};$2~/-+\+-+/&&!$1{++on;next};on&&$2&&!$1{print $2}' | while read -r cmd; do
	ln -s "$(realpath --relative-to "${PREFIX}/bin" "${TGT}/dispatcher")" "${PREFIX}/bin/${cmd}"
done
