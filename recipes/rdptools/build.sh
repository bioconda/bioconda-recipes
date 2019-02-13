#!/bin/bash

make

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cp -R *.jar ${TGT}
cp -R lib ${TGT}

cp $RECIPE_DIR/AbundanceStats.py $TGT/AbundanceStats
ln -s $TGT/AbundanceStats $PREFIX/bin
chmod 0755 "${PREFIX}/bin/AbundanceStats"

cp $RECIPE_DIR/AbundanceStats.py $TGT/AlignmentTools
sed -i.bak 's/AbundanceStats/AlignmentTools/' $TGT/AlignmentTools
ln -s $TGT/AlignmentTools $PREFIX/bin
chmod 0755 "${PREFIX}/bin/AlignmentTools"

cp $RECIPE_DIR/AbundanceStats.py $TGT/Clustering
sed -i.bak 's/AbundanceStats/Clustering/' $TGT/Clustering
ln -s $TGT/Clustering $PREFIX/bin
chmod 0755 "${PREFIX}/bin/Clustering"

cp $RECIPE_DIR/AbundanceStats.py $TGT/FrameBot
sed -i.bak 's/AbundanceStats/FrameBot/' $TGT/FrameBot
ln -s $TGT/FrameBot $PREFIX/bin
chmod 0755 "${PREFIX}/bin/FrameBot"

cp $RECIPE_DIR/AbundanceStats.py $TGT/KmerFilter
sed -i.bak 's/AbundanceStats/KmerFilter/' $TGT/KmerFilter
ln -s $TGT/KmerFilter $PREFIX/bin
chmod 0755 "${PREFIX}/bin/KmerFilter"

cp $RECIPE_DIR/AbundanceStats.py $TGT/ProbeMatch
sed -i.bak 's/AbundanceStats/ProbeMatch/' $TGT/ProbeMatch
ln -s $TGT/ProbeMatch $PREFIX/bin
chmod 0755 "${PREFIX}/bin/ProbeMatch"

cp $RECIPE_DIR/AbundanceStats.py $TGT/ReadSeq
sed -i.bak 's/AbundanceStats/ReadSeq/' $TGT/ReadSeq
ln -s $TGT/ReadSeq $PREFIX/bin
chmod 0755 "${PREFIX}/bin/ReadSeq"

cp $RECIPE_DIR/AbundanceStats.py $TGT/SeqFilters
sed -i.bak 's/AbundanceStats/SeqFilters/' $TGT/SeqFilters
ln -s $TGT/SeqFilters $PREFIX/bin
chmod 0755 "${PREFIX}/bin/SeqFilters"

cp $RECIPE_DIR/AbundanceStats.py $TGT/SequenceMatch
sed -i.bak 's/AbundanceStats/SequenceMatch/' $TGT/SequenceMatch
ln -s $TGT/SequenceMatch $PREFIX/bin
chmod 0755 "${PREFIX}/bin/SequenceMatch"

cp $RECIPE_DIR/AbundanceStats.py $TGT/hmmgs
sed -i.bak 's/AbundanceStats/hmmgs/' $TGT/hmmgs
ln -s $TGT/hmmgs $PREFIX/bin
chmod 0755 "${PREFIX}/bin/hmmgs"

cp $RECIPE_DIR/AbundanceStats.py $TGT/classifier
sed -i.bak 's/AbundanceStats/classifier/' $TGT/classifier
ln -s $TGT/classifier $PREFIX/bin
chmod 0755 "${PREFIX}/bin/classifier"
