#!/bin/sh
set -x -e

#import
export CFLAGS="-I$PREFIX/include"
export CPPFLAGS="-I$PREFIX/include"
export CXXFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include
export C_INCLUDE_PATH=${C_INCLUDE_PATH}:${PREFIX}/include
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

# General info
LTR_FINDER_DIR=${PREFIX}/share/LTR_Finder
PERL_PRG="genome_plot.pl"
PERL_OTHER_PRG="check_result.pl down_tRNA.pl filter_rt.pl genome_plot2.pl genome_plot_svg.pl"
C_PRG="ltr_finder psearch"

# Create folders
mkdir -p ${PREFIX}/bin
mkdir -p ${LTR_FINDER_DIR}
cp -r * ${LTR_FINDER_DIR}

cd source
make CC=$CC CXX=$CXX

#set C scripts
for name in ${C_PRG} ; do
  cp ${C_PRG} ${PREFIX}/bin/
done

# set perl scripts
# Set env variables for config parameters needed in RepModelConfig.pm
cat <<END >>${PREFIX}/bin/${PERL_PRG}
#!/bin/bash
NAME=\$(basename \$0)
perl ${LTR_FINDER_DIR}/\${NAME} \$@
END

chmod a+x ${PREFIX}/bin/${PERL_PRG}
for name in ${PERL_OTHER_PRG} ; do
  ln -s ${PREFIX}/bin/${PERL_PRG} ${PREFIX}/bin/$(basename $name)
done
