#!/bin/bash

echo "DEBUGGING environment info because PREFIX did not appear to be set"
echo "PREFIX=$PREFIX    CONDA_PREFIX=$CONDA_PREFIX"
set
# note that for version 3.7 the make command should be:
# make CXX="$CXX $LDFLAGS" CPPFLAGS="$CXXFLAGS" PREFIX="$PREFIX" CONDA_DB_DIR="$CONDA_PREFIX/share/amrfinderplus/data"

echo "make CXX=\"$CXX $LDFLAGS\" CPPFLAGS=\"$CXXFLAGS\" PREFIX=\"$PREFIX\" DEFAULT_DB_DIR=\"$PREFIX/share/amrfinderplus/data\""
echo "END DEBUGGING environment info because PREFIX did not appear to be set"

# try patching with some changes
cat <<END | patch amrfinder.cpp
*** amrfinder.cpp        Tue Oct  6 15:52:07 2020
--- amrfinder2.cpp        Wed Oct  7 13:43:11 2020
***************
*** 422,427 ****
--- 422,429 ----
      // we're in condaland
        if (const char* s = getenv("CONDA_PREFIX")) {
          defaultDb = string (s) + string ("/share/amrfinderplus/data/latest");
+       } else if (const char* s = getenv("PREFIX")) {
+         defaultDB = string (s) + string ("/share/amrfinderplus/data/latest");
        } else {
          Warning warning (stderr);
          stderr << "This was compiled for running under bioconda, but $CONDA_PREFIX was not found" << "\n";
END

make CXX="$CXX $LDFLAGS" CPPFLAGS="$CXXFLAGS" PREFIX="$PREFIX" DEFAULT_DB_DIR="$PREFIX/share/amrfinderplus/data"
make install bindir=$PREFIX/bin
