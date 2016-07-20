#!/bin/bash

set -x -e

export CC=${PREFIX}/bin/gcc
export CXX=${PREFIX}/bin/g++
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"

make

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/share

### Start organizing

export TOP_DIR=`pwd`
export PERL_BUILD_DIR=`pwd`/perl-build
export EXEC_DIR=`pwd`/executables
export R_DIR=`pwd`/R-scripts
export JARS_DIR=`pwd`/jar-dir

#Build Perl Libs

mkdir -p perl-build/scripts

find -name "*.pl"  | xargs -I {} cp --parent {} perl-build/scripts/
cp -rf PerlLib perl-build/lib
cp Trinity perl-build/scripts
cd perl-build/scripts

find -noleaf -type f |xargs -I {} sed -i 's/$JELLYFISH_DIR\/bin\/jellyfish/jellyfish/g' {}
find -noleaf -type f |xargs -I {} sed -i 's/$FASTOOL_DIR\/fastool/fastool/g' {}
find -noleaf -type f |xargs -I {} sed -i 's/${FASTOOL_DIR}\/fastool/fastool/g' {}
find -noleaf -type f |xargs -I {} sed -i 's/$COLLECTL_DIR\///g' {}
find -noleaf -type f |xargs -I {} sed -i 's/${COLLECTL_DIR}\///g' {}
find -noleaf -type f |xargs -I {} sed -i 's/$PARAFLY -c/ParaFly -c/g' {}
find -noleaf -type f |xargs -I {} sed -i 's/java -jar .*trimmomatic.jar/trimmomatic/g' {}
find -noleaf -type f |xargs -I {} sed -i 's/$util_dir\/...\///g' {}
find -noleaf -type f |xargs -I {} sed -i 's/$util_dir\///g' {}
find -noleaf -type f |xargs -I {} sed -i 's/$UTIL_DIR\///g' {}
find -noleaf -type f |xargs -I {} sed -i 's/$UTILDIR\/support_scripts\///g' {}
find -noleaf -type f |xargs -I {} sed -i 's/$UTILDIR\///g' {}
find -noleaf -type f |xargs -I {} sed -i 's/$MISCDIR\///g' {}
find -noleaf -type f |xargs -I {} sed -i 's/$BLAT_UTIL_DIR\///g' {}
find -noleaf -type f |xargs -I {} sed -i 's/$INCHWORM_DIR\///g' {}
find -noleaf -type f |xargs -I {} sed -i 's/$CHRYSALIS_DIR\///g' {}
find -noleaf -type f |xargs -I {} sed -i 's/$INCHWORM_DIR\/bin\///g' {}
find -noleaf -type f |xargs -I {} sed -i 's/${UTILDIR}\/support_scripts\///g' {}
find -noleaf -type f |xargs -I {} sed -i 's/$BASEDIR\/Analysis\/DifferentialExpression\///g' {}
find -noleaf -type f |xargs -I {} sed -i 's/$FindBin::RealBin\/support_scripts\///g' {}
find -noleaf -type f |xargs -I {} sed -i "s|\$TRIMMOMATIC_DIR/adapters|${PREFIX}/trimmomatic_adapters|g" {}
find -noleaf -type f |xargs -I {} sed -i "s|\$BUTTERFLY_DIR/|${PREFIX}/share/|g" {}
find -noleaf -type f |xargs -I {} sed -i "s|ExitTest.jar|${PREFIX}/share/ExitTester.jar|g" {}
find -noleaf -type f |xargs -I {} sed -i 's/java -jar $TRIMMOMATIC/trimmomatic/g' {}

cd ..

cp ${RECIPE_DIR}/Build.PL ./
${PREFIX}/bin/perl ./Build.PL
./Build manifest
./Build install installdirs site


## .sh files

cd ..
mkdir -p scripts
find -name "*sh" -type f | xargs -I {} cp -rf {} scripts/

#Other executables

cd $TOP_DIR
mkdir -p executables

cp -rf Chrysalis/BreakTransByPairs executables/
cp -rf Chrysalis/checkLock executables/
cp -rf Chrysalis/Chrysalis executables/
cp -rf Chrysalis/chrysalis.notes executables/
cp -rf Chrysalis/CreateIwormFastaBundle executables/
cp -rf Chrysalis/GraphFromFasta executables/
cp -rf Chrysalis/GraphFromFasta_MPI executables/
cp -rf Chrysalis/IsoformAugment executables/
cp -rf Chrysalis/JoinTransByPairs executables/
cp -rf Chrysalis/QuantifyGraph executables/
cp -rf Chrysalis/ReadsToTranscripts executables/
cp -rf Chrysalis/ReadsToTranscripts_MPI executables/
cp -rf Chrysalis/ReadsToTranscripts_MPI_chang executables/
cp -rf Chrysalis/RunButterfly executables/
cp -rf Chrysalis/TranscriptomeFromVaryK executables/
cp -rf Inchworm/bin/* executables/
cp -rf trinity-plugins/scaffold_iworm_contigs/scaffold_iworm_contigs  executables/

cp -rf executables/* ${PREFIX}/bin

## R Scripts

cd $TOP_DIR

mkdir -p R-Scripts
cp -rf Analysis/DifferentialExpression/R/* R-Scripts/
cp -rf Analysis/FL_reconstruction_analysis/R/* R-Scripts/
cp -rf util/R/* R-Scripts/

cp -rf R-Scripts/* ${PREFIX}/bin

# Jar Dirs

cd $TOP_DIR

mkdir -p jars_dir
find -name "*.jar" | xargs -I {} cp -rf {} jars_dir
mkdir -p ${PREFIX}/share
cp -rf jars_dir/* ${PREFIX}/share

# Sample Data

cd $TOP_DIR
#cp -rf sample_data ${PREFIX}/trinity_sample_data

#Trimmomatic Adaptors
mkdir -p ${PREFIX}/trimmomatic_adapters/
cp -rf trinity-plugins/Trimmomatic-0.32/adapters/* ${PREFIX}/trimmomatic_adapters/

#HPC confs

cp -rf hpc_conf ${PREFIX}/trinity_htc_conf

#

#exit 1
