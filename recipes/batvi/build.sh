cd source
mkdir -p $PREFIX/bin/msapipeline/msa
mkdir -p $PREFIX/bin/bin
mkdir -p $PREFIX/bin/BatMis-3.00/bin
mkdir -p $PREFIX/bin/batindel/src
export CFLAGS="${CFLAGS} -fcommon"
export CXXFLAGS="${CXXFLAGS} -fcommon"



# copy contents from build script, but add ./configure params:
### BEGIN ### copied from ./build.sh

        echo ==========================================================
        echo                COMPILING BatMis
        echo ==========================================================
        cd BatMis-3.00
        if [[ ${target_platform} == osx-64 ]]; then
            sed -i.bak 's/ -maccumulate-outgoing-args/ -Dfopen64=fopen -Dfseeko64=fseeko -Dftello64=ftello -Dlseek64=lseek -Doff64_t=off_t/' src/Makefile.am
        fi
        autoreconf -fi
        ./configure CC="${CC}" CXX="${CXX}" CPPFLAGS="${CPPFLAGS}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}"
        make
        make copy
        cd -

        echo ==========================================================
        echo                COMPILING BATINDEL-lite
        echo ==========================================================
        cd batindel
        if [[ ${target_platform} == osx-64 ]]; then
            sed -i.bak 's/ -maccumulate-outgoing-args/ -Dfopen64=fopen -Dfseeko64=fseeko -Dftello64=ftello -Dlseek64=lseek -Doff64_t=off_t/' src/Makefile.am
        fi
        autoreconf -fi
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

###  END  ### copied from ./build.sh



cp *.{sh,pl} $PREFIX/bin
cp bin/*.{sh,pl} $PREFIX/bin/bin
cp bin/cluster_bp $PREFIX/bin/bin
cp msapipeline/*.{sh,pl} $PREFIX/bin/msapipeline
cp msapipeline/msa/*.class $PREFIX/bin/msapipeline/msa
cp BatMis-3.00/bin/* $PREFIX/bin/BatMis-3.00/bin
cp batindel/src/penguin $PREFIX/bin/batindel/src
