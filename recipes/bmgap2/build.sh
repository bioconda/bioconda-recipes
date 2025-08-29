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
find $sharedb -type f -name 'species_db_*' -exec cp -vf {} $PREFIX/bin/ \;
find $sharedb -type f -name 'RefSeqSketchesDefaults.msh*' -exec cp -vf {} $PREFIX/bin/ \;
find $sharedb -type f -name 'blast_db*' -exec cp -vf {} $PREFIX/bin/ \;
find $sharedb -type f -name 'sqlite3_db*' -exec cp -vf {} $PREFIX/bin/ \;

