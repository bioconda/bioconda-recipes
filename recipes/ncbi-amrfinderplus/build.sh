#!/bin/bash

echo "DEBUGGING environment info because PREFIX did not appear to be set"
echo "PREFIX=$PREFIX    CONDA_PREFIX=$CONDA_PREFIX"
set
# note that for version 3.7 the make command should be:
# make CXX="$CXX $LDFLAGS" CPPFLAGS="$CXXFLAGS" PREFIX="$PREFIX" CONDA_DB_DIR="$CONDA_PREFIX/share/amrfinderplus/data"

echo "make CXX=\"$CXX $LDFLAGS\" CPPFLAGS=\"$CXXFLAGS\" PREFIX=\"$PREFIX\" DEFAULT_DB_DIR=\"$PREFIX/share/amrfinderplus/data\""
echo "END DEBUGGING environment info because PREFIX did not appear to be set"

# try patching with some changes. This is necessary because CONDA_PREFIX is not set on test system. 
# it should be set when using conda on the commandline
cat <<END | patch amrfinder.cpp
--- a/amrfinder.cpp
+++ b/amrfinder.cpp
@@ -422,6 +422,11 @@ struct ThisApplication : ShellApplication
     // we're in condaland
       if (const char* s = getenv("CONDA_PREFIX")) {
         defaultDb = string (s) + string ("/share/amrfinderplus/data/latest");
+      } else if (const char* s = getenv("PREFIX")) {
+        Warning warning (stderr);
+        stderr << "This was compiled for running under bioconda, but $CONDA_PREFIX was not found" << "\n";
+        defaultDb = string (s) + string ("/share/amrfinderplus/data/latest");
+        stderr << "Reverting to $PREFIX: " << defaultDb;
       } else {
         Warning warning (stderr);
         stderr << "This was compiled for running under bioconda, but $CONDA_PREFIX was not found" << "\n";
END

make CXX="$CXX $LDFLAGS" CPPFLAGS="$CXXFLAGS" PREFIX="$PREFIX" DEFAULT_DB_DIR="$PREFIX/share/amrfinderplus/data"
make install bindir=$PREFIX/bin
