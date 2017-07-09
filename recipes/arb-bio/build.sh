#!/bin/bash
set -x

#### "./configure" ####

export ARBHOME=`pwd`
export PATH="$ARBHOME/bin:$PATH"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$ARBHOME/lib"

export PKG_CONFIG_LIBDIR="$PREFIX/lib/pkgconfig:$PREFIX/share/pkgconfig"
export XLIBS=$(pkg-config --libs xpm xerces-c)
export XAW_LIBS=$(pkg-config --libs xaw7)
export XML_INCLUDES=$(pkg-config --cflags xerces-c)
export XINCLUDES=$(pkg-config --cflags x11)

## Suppress building tools bundled with ARB for which we have
# conda packages:
export ARB_BUILD_SKIP_PKGS="MAFFT MUSCLE RAxML PHYLIP FASTTREE MrBAYES"

# ARB stores build settings in config.makefile. Create one from template:
cp config.makefile.template config.makefile

# Now add some target specific settings to config.makefile
case `uname` in
    Linux)
	echo DARWIN := 0
	echo LINUX := 1
	echo MACH := LINUX
	echo LINK_STATIC := 0
	SHARED_LIB_SUFFIX=so
	;;
    Darwin)
	echo DARWIN := 1
	echo LINUX := 0
	echo MACH := DARWIN
	echo LINK_STATIC := 0
	SHARED_LIB_SUFFIX=dylib
	export CFLAGS="$CFLAGS -w"
	# needed for ARB Perl Binding compilation using MakeMaker
	export LDFLAGS="$LDFLAGS -Wl,-rpath,$PREFIX/lib"
	;;
esac >> config.makefile

#### "make" ####

make SHARED_LIB_SUFFIX=$SHARED_LIB_SUFFIX -j$CPU_COUNT build | sed 's|'$PREFIX'|$PREFIX|g'

#### "make install" ####

# create tarballs (picks the necessary files out of build tree)
make SHARED_LIB_SUFFIX=$SHARED_LIB_SUFFIX tarfile_quick | sed 's|'$PREFIX'|$PREFIX|g'

# unpack tarballs at $PREFIX
ARB_INST=$PREFIX/lib/arb
mkdir $ARB_INST
tar -C $ARB_INST -xzf arb.tgz
tar -C $ARB_INST -xzf arb-dev.tgz

# symlink arb_* executables into PATH
(
 cd $PREFIX/bin;
 for exe in $ARB_INST/bin/arb*; do
     ln -s "$exe"
 done
)

# fix the library paths
case `uname` in
    Darwin)
	# fix library IDs
	# ARB builds libraries as "-o ../lib/libXYZ.suf". That value becomes the
	# "ID" of the lib and the path searched for by binaries. We need to
	# change all these...

	declare -a CHANGE_IDS
	ARB_LIBS="$ARB_INST"/lib/*.$SHARED_LIB_SUFFIX
	for lib in $ARB_LIBS; do
	    old_id=`otool -D "$lib" | tail -n 1`
	    new_id="@rpath/${lib##$PREFIX/lib/}"
	    CHANGE_IDS+=("-change" "$old_id" "$new_id")
	    install_name_tool -id "$new_id" "$lib"
	    echo "Fixing ID of $lib ($old_id => $new_id)"
	done
	echo "Collected changes to me made:"
	echo "${CHANGE_IDS[@]}"

	ARB_BINS=`find $ARB_INST -type f -perm -a=x | \
	    xargs file | grep Mach-O | cut -d : -f 1 | grep -v ' '`

	echo "Applying changes to binaries:"
	for bin in $ARB_BINS; do
	    if test -e "$bin"; then
		echo -n "$bin ... "
		install_name_tool "${CHANGE_IDS[@]}" "$bin"
		echo "done"
	    fi
	done
	;;
    Linux)
	ARB_BINS=`find $ARB_INST -type f -perm -a=x | \
	    xargs file | grep ELF | cut -d : -f 1 | grep -v ' '`
	echo "Patching rpath into binaries:"
	for bin in $ARB_BINS; do
	    if test -e "$bin"; then
		echo -n "$bin ..."
		patchelf --set-rpath \$ORIGIN/../lib "$bin"
	    fi
	done
	;;
esac

# Create [de]activate scripts
# (ARB components expect ARBHOME set to the installation directory)

mkdir -p "${PREFIX}/etc/conda/activate.d"
cat >"${PREFIX}/etc/conda/activate.d/arbhome-activate.sh" <<EOF
export ARBHOME_BACKUP="\$ARBHOME"
export ARBHOME="\$CONDA_PREFIX/lib/arb"
EOF
mkdir -p "${PREFIX}/etc/conda/deactivate.d"
cat >"${PREFIX}/etc/conda/deactivate.d/arbhome-deactivate.sh" <<EOF
export ARBHOME="\$ARB_HOMEBACKUP"
EOF

