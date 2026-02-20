#!/bin/bash
set -x -e

#import
export CFLAGS="${CFLAGS} -O3 -fomit-frame-pointer -DNDBUG -I$PREFIX/include -Wno-register"
export CPPFLAGS="${CPPFLAGS} -I$PREFIX/include -Wno-register"
export CXXFLAGS="${CXXFLAGS} -fomit-frame-pointer -DNDBUG -O3 -I$PREFIX/include -Wno-register"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"
export LIBRARY_PATH="${PREFIX}/lib"

case $(uname -m) in
    aarch64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
	;;
    arm64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
	;;
    x86_64)
	export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
	;;
esac

# General info
LTR_FINDER_DIR=${PREFIX}/share/LTR_Finder
PERL_PRG="genome_plot.pl"
PERL_OTHER_PRG="check_result.pl down_tRNA.pl filter_rt.pl genome_plot2.pl genome_plot_svg.pl"
C_PRG="ltr_finder psearch"

# Create folders
mkdir -p ${PREFIX}/bin
mkdir -p ${LTR_FINDER_DIR}
cp -rf * ${LTR_FINDER_DIR}

cd source
make CC="${CC}" CXX="${CXX}" CFLAGS="${CFLAGS}" CPPFLAGS="${CXXFLAGS}"

#set C scripts
for name in ${C_PRG} ; do
  install -v -m 0755 ${C_PRG} "${PREFIX}/bin"
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
  ln -sf ${PREFIX}/bin/${PERL_PRG} ${PREFIX}/bin/$(basename $name)
done
