export C_INCLUDE_PATH=$C_INCLUDE_PATH:${PREFIX}/include
export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:${PREFIX}/include
export LIBRARY_PATH=$LIBRARY_PATH:${PREFIX}/lib
mkdir -p $PREFIX/bin/msapipeline/msa
mkdir -p $PREFIX/bin/bin
mkdir -p $PREFIX/bin/BatMis-3.00/bin
mkdir -p $PREFIX/bin/batindel/src



# copy contents from build script, but add ./configure params:
### BEGIN ### copied from ./build.sh

        echo ==========================================================
        echo                COMPILING BatMis
        echo ==========================================================
        cd BatMis-3.00
        ./configure CC="${CC}" CXX="${CXX}" CPPFLAGS="${CPPFLAGS}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}"
        make
        make copy
        cd -

        echo ==========================================================
        echo                COMPILING BATINDEL-lite
        echo ==========================================================
        cd batindel
        ./configure CC="${CC}" CXX="${CXX}" CPPFLAGS="${CPPFLAGS}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}"
        make
        cd -

        echo ==========================================================
        echo                COMPILING Binaries
        echo ==========================================================
        cd bin
        sed -i.bak -e 's/^gcc/"${CC}"/' -e 's/^g++/"${CXX}"/' ./build.sh
        ./build.sh
        cd -

        echo ==========================================================
        echo                COMPILING MSA
        echo ==========================================================
        cd msapipeline/msa
        javac *.java
        cd -

  ./manualcompile.sh

        command -v blastn >/dev/null 2>&1 || { echo >&2 "Please check if BLAST is installed"; }
        command -v bwa >/dev/null 2>&1 || { echo >&2 "Please check if BWA is installed"; }

###  END  ### copied from ./build.sh



cp *.{sh,pl} $PREFIX/bin
cp bin/*.{sh,pl} $PREFIX/bin/bin
cp bin/cluster_bp $PREFIX/bin/bin
cp msapipeline/*.{sh,pl} $PREFIX/bin/msapipeline
cp msapipeline/msa/*.class $PREFIX/bin/msapipeline/msa
cp BatMis-3.00/bin/* $PREFIX/bin/BatMis-3.00/bin
cp batindel/src/penguin $PREFIX/bin/batindel/src
