#!/bin/bash
echo "====== BUILDER STARTED ========"

# set up environment variables
export ARBHOME=`pwd`
export PATH="$ARBHOME/bin:$PATH"

case `uname` in
    Linux)
	SHARED_LIB_SUFFIX=so
	export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$ARBHOME/lib"
	;;
    Darwin)
	SHARED_LIB_SUFFIX=dylib
	export CFLAGS="$CFLAGS -w"
	# needed for ARB Perl Binding compilation using MakeMaker
	export LDFLAGS="$LDFLAGS -Wl,-rpath,$PREFIX/lib"
	;;
esac

echo "====== PREPARING CONFIG ========"
# ARB stores build settings in config.makefile. Create one from template:
cp config.makefile.template config.makefile

# Now add some target specific settings to config.makefile
case `uname` in
    Linux)
	echo DARWIN := 0
	echo LINUX := 1
	echo MACH := LINUX
	echo LINK_STATIC := 0
	;;
    Darwin)
	echo DARWIN := 1
	echo LINUX := 0
	echo MACH := DARWIN
	echo LINK_STATIC := 0
	;;
esac >> config.makefile

echo "====== STARTING BUILD ========"
# Suppress building tools bundled with ARB for which we have
# conda packages:
export ARB_BUILD_SKIP_PKGS="MAFFT MUSCLE RAxML PHYLIP FASTTREE MrBAYES"

export PKG_CONFIG_LIBDIR="$PREFIX/lib/pkgconfig:$PREFIX/share/pkgconfig"
export XLIBS=$(pkg-config --libs xpm xerces-c)
export XAW_LIBS=$(pkg-config --libs xaw7)
export XML_INCLUDES=$(pkg-config --cflags xerces-c)
export XINCLUDES=$(pkg-config --cflags x11)

make SHARED_LIB_SUFFIX=$SHARED_LIB_SUFFIX -j$CPU_COUNT build \
    | sed 's|'$PREFIX'|$PREFIX|g' > build.log || (cat build.log; false)

# create tarballs (picks the necessary files out of build tree)
make SHARED_LIB_SUFFIX=$SHARED_LIB_SUFFIX tarfile_quick \
    | sed 's|'$PREFIX'|$PREFIX|g' > build.log || (cat build.log; false)

echo "====== FINISHED BUILD ========"


mkdir -p install/lib/arb
tar -C install/lib/arb -xzf arb.tgz


# Manually relocate libraries and binaries
#
# ARB builds libraries as "-o ../lib/libXYZ.suf". This path becomes the
# "ID" / rpath of the lib and the path at which binaries claim their libs
# can be found.
case `uname` in
    Darwin)
	declare -a CHANGE_IDS # changes to be made to binaries
	ARB_LIBS=install/lib/arb/lib/*.$SHARED_LIB_SUFFIX # libs to move

	for lib in $ARB_LIBS; do
	    old_id=`otool -D "$lib" | tail -n 1`
	    new_id="@rpath/${lib##install/lib/}"
	    CHANGE_IDS+=("-change" "$old_id" "$new_id")
	    install_name_tool -id "$new_id" "$lib"
	    echo "Fixing ID of $lib ($old_id => $new_id)"
	done

	echo "Collected changes to me made:"
	echo "${CHANGE_IDS[@]}"

	ARB_BINS=`find install -type f -perm -a=x | \
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
	ARB_BINS=`find install -type f -perm -a=x | \
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

