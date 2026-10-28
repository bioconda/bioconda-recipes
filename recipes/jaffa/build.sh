#!/bin/bash

# Setup path variables
BINARY_HOME=$PREFIX/bin
PACKAGE_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

# Create destination directories
mkdir -p $PACKAGE_HOME
mkdir -p ${PREFIX}/bin

# Copy files over into $PACKAGE_HOME
cp -aR * $PACKAGE_HOME

# Compile JAFFA's helper programs into the conda environment. These binaries
# must match the Groovy pipeline from the same JAFFA release.
for tool in \
    process_transcriptome_align_table \
    make_3_gene_fusion_table \
    make_count_table \
    make_final_table \
    extract_seq_from_fasta \
    make_simple_read_table \
    make_simple_read_table_assembly \
    compile_results \
    split_fusion_reads; do
    $CXX -std=c++11 -O3 -o "$PREFIX/bin/$tool" "$PACKAGE_HOME/src/$tool.c++"
done

# Create wrappers
SOURCE_FILE=$RECIPE_DIR/run-jaffa.sh
for suffix in direct assembly hybrid jaffal; do
    DEST_FILE=$PACKAGE_HOME/jaffa-$suffix

    echo "#!/bin/bash" > $DEST_FILE
    echo "PKG_NAME=$PKG_NAME" >> $DEST_FILE
    echo "PKG_VERSION=$PKG_VERSION" >> $DEST_FILE
    echo "PACKAGE_HOME=$PACKAGE_HOME" >> $DEST_FILE
    echo "RUNMODE=$suffix" >>$DEST_FILE
    cat $SOURCE_FILE >> $DEST_FILE

    chmod +x $DEST_FILE
    if [ "$suffix" = "jaffal" ]; then
        ln -s $DEST_FILE $PREFIX/bin/jaffal
    else
        ln -s $DEST_FILE $PREFIX/bin/jaffa-$suffix
    fi
done
