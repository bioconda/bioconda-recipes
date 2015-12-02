#! /bin/bash

# ls -1 bin/ | grep -v old | sed -e "s/\*/ \\\/g"
binaries="\
GenomeOntology.pl \
HomerConfig.pm \
SIMA.pl \
Statistics.pm
addData.pl \
addDataHeader.pl \
addGeneAnnotation.pl \
addInternalData.pl \
addOligos.pl \
adjustPeakFile.pl \
adjustRedunGroupFile.pl \
analyzeChIP-Seq.pl \
analyzeHiC \
analyzeRNA.pl \
analyzeRepeats.pl \
annotateInteractions.pl \
annotatePeaks.pl \
annotateRelativePosition.pl \
annotateTranscripts.pl \
assignGeneWeights.pl \
assignGenomeAnnotation \
assignTSStoGene.pl \
batchAnnotatePeaksHistogram.pl \
batchFindMotifs.pl \
batchFindMotifsGenome.pl \
batchMakeTagDirectory.pl \
batchParallel.pl \
bed2pos.pl \
bed2tag.pl \
changeNewLine.pl \
checkPeakFile.pl \
checkTagBias.pl \
chopUpBackground.pl \
chopUpPeakFile.pl \
chopify.pl \
cleanUpPeakFile.pl \
cleanUpSequences.pl \
cluster2bed.pl \
cluster2bedgraph.pl \
compareMotifs.pl \
condenseBedGraph.pl \
cons2fasta.pl \
conservationAverage.pl \
conservationPerLocus.pl \
convertCoordinates.pl \
convertIDs.pl \
convertOrganismID.pl \
duplicateCol.pl \
eland2tags.pl \
fasta2tab.pl \
fastq2fasta.pl \
filterListBy.pl \
findGO.pl \
findGOtxt.pl \
findHiCCompartments.pl \
findHiCDomains.pl \
findHiCInteractionsByChr.pl \
findKnownMotifs.pl \
findMotifs.pl \
findMotifsGenome.pl \
findPeaks \
findRedundantBLAT.pl \
findTopMotifs.pl \
freq2group.pl \
genericConvertIDs.pl \
genomeOntology \
getChrLengths.pl \
getConservedRegions.pl \
getDiffExpression.pl \
getDifferentialBedGraph.pl \
getDifferentialPeaks \
getDistalPeaks.pl \
getFocalPeaks.pl \
getGWASoverlap.pl \
getGenesInCategory.pl \
getGenomeTilingPeaks \
getHiCcorrDiff.pl \
getMappableRegions \
getPartOfPromoter.pl \
getPeakTags \
getPos.pl \
getRandomReads.pl \
getSiteConservation.pl \
getTopPeaks.pl \
gff2pos.pl \
go2cytoscape.pl \
groupSequences.pl \
homer \
homer2 \
homerTools \
joinFiles.pl \
loadGenome.pl \
loadPromoters.pl \
makeBigBedMotifTrack.pl \
makeBigWig.pl \
makeBinaryFile.pl \
makeHiCWashUfile.pl \
makeMultiWigHub.pl \
makeTagDirectory \
makeUCSCfile \
map-bowtie2.pl \
map-star.pl \
mergeData.pl \
mergePeaks \
motif2Jaspar.pl \
motif2Logo.pl \
parseGTF.pl \
pos2bed.pl \
prepForR.pl \
preparseGenome.pl \
profile2seq.pl \
qseq2fastq.pl \
randRemoveBackground.pl \
randomizeGroupFile.pl \
randomizeMotifs.pl \
removeAccVersion.pl \
removeBadSeq.pl \
removeOutOfBoundsReads.pl \
removePoorSeq.pl \
removeRedundantPeaks.pl \
renamePeaks.pl \
resizePosFile.pl \
revoppMotif.pl \
runHiCpca.pl \
scanMotifGenomeWide.pl \
scrambleFasta.pl \
seq2profile.pl \
tab2fasta.pl \
tag2bed.pl \
tag2pos.pl \
tagDir2HiCsummary.pl \
tagDir2bed.pl \
zipHomerResults.pl \
"



outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $outdir/bin
mkdir -p $PREFIX/bin
chmod +x configureHomer.pl
cp configureHomer.pl $outdir/

cd $PREFIX/bin
# Add helper script to configureHomer.pl so that configureHomer.pl
# -install really installs in $outdir
configureHomer=$PREFIX/bin/configureHomer.pl
echo "#! /bin/bash" > $configureHomer;
echo 'DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )' >>  $configureHomer;
echo '$DIR/../share/'$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/configureHomer.pl >> $configureHomer;
chmod +x $configureHomer;

# Note that homer cannot be built as a package since the installation
# script *hard-codes* the paths in the perl scripts. Nevertheless,
# create symlinks to $outdir/bin as this is where configureHomer.pl
# -install will put the binaries
for i in $binaries; do ln -s $outdir/bin/$i $PREFIX/bin/$i; done
