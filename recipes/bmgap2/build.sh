#!/bin/bash

mkdir -pv $PREFIX/bin
mkdir -pv $PREFIX/src

# executables are sh and py scripts
find analysis_scripts/ -type f -name '*.py' -exec cp -vf {} $PREFIX/bin/ \;
find analysis_scripts/ -type f -name '*.sh' -exec cp -vf {} $PREFIX/bin/ \;
# ensure they can be executed
chmod +x $PREFIX/bin/*.py $PREFIX/bin/*.sh

# scripts in bmgap2 look for scripts in analysis_scripts and so make a simple symlink
ln -sv $PREFIX/bin $PREFIX/analysis_scripts
cp -vf BMGAP-RUNNER.sh $PREFIX/bin/
find $PREFIX/analysis_scripts -maxdepth 2 -type f -executable | while read exe; do
  name=$(basename $exe)
  ln -sv $exe $PREFIX/bin/$name
done

ls -CF $PREFIX/bin
find $PREFIX/bin/ -iname '*sql*' | xargs ls -lhSR

exit 0

# Will need to install databases, etc. later
sharedb=$PREFIX/share/${PKG_NAME}-${PKG_VERSION}
mkdir -pv $sharedb

# I know this could have been done in one command,
# but I wanted to make each item clear on what is being copied.
(
  set -e
  cd analysis_scripts
  cp -rvf amr_variants_component $sharedb/
  cp -rvf locusextractor $sharedb/
  cp -rvf PMGA $sharedb/
  cp -rvf SpeciesDB $sharedb/
)

# some scripts require local database files and so I unfortunately have to put that into bin
#find $sharedb -type f -name 'species_db_*' -exec cp -vf {} $PREFIX/bin/ \;
#find $sharedb -type f -name 'RefSeqSketchesDefaults.msh*' -exec cp -vf {} $PREFIX/bin/ \;
#find $sharedb -type f -name 'blast_db*' -exec cp -vf {} $PREFIX/bin/ \;
#find $sharedb -type d -name 'sqlite3_db*' -exec cp -rvf {} $PREFIX/bin/ \;

# There are library files that are expected to be in the binary paths,
# in a subfolder lib
set -ex
mkdir -pv $PREFIX/bin/lib
cp -vf $sharedb/*/lib/* $PREFIX/bin/lib/
# Sqlite3 DBS are expected to be in a subfolder sqlite3_db
mkdir -pv $PREFIX/bin/sqlite3_db
cp -vf $sharedb/*/sqlite3_db/* $PREFIX/bin/sqlite3_db/
# some scripts are expected to be in a subfolder bin
mkdir -pv $PREFIX/bin/bin
cp -vf $sharedb/*/bin/* $PREFIX/bin/bin/
# Some scripts at least in PMGA are in a subfolder custom_allele_sets
# and custom_allele_sets itself has subdirectories
mkdir -pv $PREFIX/bin/custom_allele_sets/{hinfluenzae,neisseria}
cp -rvf $sharedb/*/custom_allele_sets/hinfluenzae/* $PREFIX/bin/custom_allele_sets/hinfluenzae/
cp -rvf $sharedb/*/custom_allele_sets/neisseria/* $PREFIX/bin/custom_allele_sets/neisseria/
# locusextractor has a lot of subfolders too!
for dir in $sharedb/locusextractor/*; do
  if [ -d "$dir" ]; then
    subdir=$(basename $dir)
    mkdir -pv $PREFIX/bin/locusextractor/$subdir
    cp -rvf $sharedb/locusextractor/$subdir/* $PREFIX/bin/locusextractor/$subdir/
  fi
done

echo "===== Contents of $PREFIX/bin/:"
ls -CF $PREFIX/bin/
ls -lhS $PREFIX/bin/sqlite3_db/
