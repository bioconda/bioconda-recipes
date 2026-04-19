AC_PREREQ([2.71])

AC_INIT([Rgraphviz],[1.x],[biocore@stat.math.ethz.ch],[Rgraphviz])

dnl We want the following logic
dnl Per default, use the included graphviz and set GRAPHVIZ_DIR, GRAPHVIZ_VERSTR and do compilation of graphviz
dnl Otherwise, specify location of graphviz using --with-graphviz

AC_ARG_WITH(graphviz,
           [AS_HELP_STRING([--with-graphviz=DIR],
                           [root directory of Graphviz installation (defaults to /usr/local)])],
           [GRAPHVIZ_DIR="${with_graphviz}"],
	   [GRAPHVIZ_DIR=""])

if test -z "${GRAPHVIZ_DIR}" ; then
    AC_MSG_NOTICE([Using bundled Graphviz.])
    BUILD_DIR="`pwd`"
    AC_MSG_NOTICE([Searching for the compilers specified by R.])
    : ${R_HOME=`R RHOME`}
    if test -z "${R_HOME}"; then
      echo "could not determine R_HOME"
      exit 1
    fi
    CC=`"${R_HOME}/bin/R" CMD config CC17`
    CFLAGS=`"${R_HOME}/bin/R" CMD config C17FLAGS`
    CPPFLAGS=`"${R_HOME}/bin/R" CMD config CPPFLAGS`
    CXX=`"${R_HOME}/bin/R" CMD config CXX17`
    CXXFLAGS=`"${R_HOME}/bin/R" CMD config CXX17FLAGS`
    LDFLAGS=`"${R_HOME}/bin/R" CMD config LDFLAGS`
    MAKE=`"${R_HOME}/bin/R" CMD config MAKE`
    AC_PROG_CC
    AC_PROG_CPP
    AC_PROG_CXX
    AC_MSG_NOTICE([Preparing to compile Graphviz.])
    cd src/graphviz
    touch configure 
    touch libltdl/configure
    BUILD_INSTALL_DIR="${BUILD_DIR}/src/libunix"
    rm -rf ${BUILD_INSTALL_DIR}
    AC_MSG_NOTICE([Configuring bundled Graphviz.])
    autoreconf -if
    ./configure\
        CC="${CC}" CXX="${CXX}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}"\
	LDFLAGS="${LDFLAGS}"\
        --prefix="${BUILD_INSTALL_DIR}"\
        --libdir="${BUILD_INSTALL_DIR}/lib"\
        --includedir="${BUILD_INSTALL_DIR}/include"\
        --with-cgraph=no\
        --enable-swig=no\
        --enable-static\
        --disable-shared\
        --with-pic\
        --with-libgd=no\
        --disable-ltdl\
        --without-x\
        --without-expat\
        --without-devil\
        --without-rsvg\
        --without-ghostscript\
        --without-visio\
        --without-pangocairo\
        --without-lasi\
        --without-glitz\
        --without-freetype2\
        --without-fontconfig\
        --without-rpat\
        --without-glut\
        --without-gts\
        --without-png\
        --without-tcl\
        --without-jpeg
    ${MAKE} install
    cd "${BUILD_DIR}"
    BUILD_INCLUDE_DIR="${BUILD_INSTALL_DIR}/include/graphviz"
    BUILD_LIB_DIR="${BUILD_INSTALL_DIR}/lib"
    cp "${BUILD_LIB_DIR}"/* "${BUILD_LIB_DIR}"/graphviz/* "${BUILD_DIR}"/src
    GRAPHVIZ_VERSION="2.28.0"
    GRAPHVIZ_BUNDLED="TRUE"
    PKG_LIBS="libxdot.a libgvplugin_dot_layout.a libgvplugin_neato_layout.a libgvplugin_core.a libgvc.a libpathplan.a libgraph.a libcdt.a"
    AC_CHECK_HEADER(zlib.h,
                    [AC_CHECK_LIB(z,deflateBound,[PKG_LIBS="${PKG_LIBS} -lz"],,)],)
    AC_SEARCH_LIBS([pow], [m], [PKG_LIBS="${PKG_LIBS} -lm"],,) 
    PKG_CFLAGS="${PKG_CFLAGS} -I${BUILD_INCLUDE_DIR}"
    GVIZ_DEFS="-DGRAPHVIZ_MAJOR=2 -DGRAPHVIZ_MINOR=28 -DGRAPHVIZ_STATIC"
else
    AC_MSG_NOTICE([Using external Graphviz.])
    GRAPHVIZ_BUNDLED="FALSE"

    dnl The logic is as follows:
    dnl Either the user specifically points us to graphviz using --with-graphviz='/something'
    dnl Or the intention to use external graphviz is indicated by --with-graphviz  
    if test "${GRAPHVIZ_DIR}" = "yes"; then
        dnl Since the user did not specify a directory, we first try pkg-config and then we will use /usr/local
        AC_MSG_NOTICE([No directory was specified for --with-graphviz. Trying to find Graphviz using other methods.])
        if test -z "${PKG_CONFIG}" ; then
            AC_PATH_PROG(PKG_CONFIG, pkg-config)
        fi
        if ! test -z "${PKG_CONFIG}" ; then
            GRAPHVIZ_CONFIG="${PKG_CONFIG} libgvc"
            GRAPHVIZ_VERSION="`${GRAPHVIZ_CONFIG} --modversion || echo ''`"
            if test -z "${GRAPHVIZ_VERSION}" ; then
                AC_MSG_NOTICE([pkg-config was not able to find the Graphviz library libgvc. This either indicates that Graphviz is old or that something is wrong. Verify Graphviz is installed and that PKG_CONFIG_PATH is correct.])
                AC_MSG_NOTICE([Trying with /usr/local anyway."])
                GRAPHVIZ_DIR="/usr/local"
            else
                PKG_CFLAGS="`${GRAPHVIZ_CONFIG} --cflags`"
                PKG_LIBS="`${GRAPHVIZ_CONFIG} --libs`"
            fi
        fi
    fi

    dnl At this point, either GRAPHVIZ_DIR is yes (using pkg-config worked) or
    dnl it is set to something else, in which case we use dot to get the version number
    if ! test "${GRAPHVIZ_DIR}" = "yes"; then
        AC_MSG_NOTICE([Using Graphviz dir '${GRAPHVIZ_DIR}'])
	DOT="${GRAPHVIZ_DIR}/bin/dot"
        if ! test -x "${DOT}" ; then
            AC_MSG_ERROR([$DOT not found.  Check Graphviz installation.])
            exit 1
        fi
        GRAPHVIZ_VERSION=`${DOT} -V 2>&1 | cut -f3 -d" "`
        if test "${GRAPHVIZ_VERSION}" = "Graphviz"; then
            GRAPHVIZ_VERSION=`${DOT} -V 2>&1 | cut -f5 -d" "`
        fi
        if test "${GRAPHVIZ_VERSION}" = "graphviz"; then
            GRAPHVIZ_VERSION=`${DOT} -V 2>&1 | cut -f5 -d" "`
        fi
        PKG_CFLAGS="-I${GRAPHVIZ_DIR}/include/graphviz"
        PKG_LIBS="-L${GRAPHVIZ_DIR}/lib/graphviz -L${GRAPHVIZ_DIR}/lib -lgvc"
    fi

    dnl At this point GRAPHVIZ_VERSION ought to exist, we do computations on it to infer MAJOR and MINOR version
    if test -z ${GRAPHVIZ_VERSION} ; then 
       AC_MSG_ERROR([Unable to determine Graphviz version. Report to Rgraphviz maintainer.])
       exit 1
    fi
    AC_MSG_NOTICE([Found Graphviz version '${GRAPHVIZ_VERSION}'.])
    MAJOR=`echo ${GRAPHVIZ_VERSION} | cut -f1 -d"."`
    MINOR=`echo ${GRAPHVIZ_VERSION} | cut -f2 -d"."`
    if test -z ${MAJOR} || test -z ${MINOR} ; then
        AC_MSG_ERROR([Unable to infer Graphviz major and minor version, report to Rgraphviz maintainer])
        exit 1
    fi
    AC_MSG_NOTICE([Graphviz major version is '${MAJOR}' and minor version is '${MINOR}'.])
    if (test ${MAJOR} -lt "2") || (test ${MAJOR} -eq "2" && test ${MINOR} -lt "16") ; then
        AC_MSG_ERROR([Need Graphviz >= 2.16])
        exit 1
    fi
    PKG_CFLAGS="${PKG_CFLAGS} -DGRAPHVIZ_MAJOR=${MAJOR} -DGRAPHVIZ_MINOR=${MINOR}"
fi

AC_HEADER_STDBOOL
AC_MSG_CHECKING([for whether compiler has bool])
AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[
   #ifdef HAVE_STDBOOL_H
   #include <stdbool.h>
   #endif
   ]], [[
   bool foo = true, bar = false;
   ]])],[
   AC_MSG_RESULT(yes)
   GVIZ_DEFS="${GVIZ_DEFS} -DHAVE_STDBOOL_H=1 -DHAVE_BOOL=1"
   ],[
   AC_MSG_RESULT(no)])

AC_MSG_NOTICE([Using the following compilation and linking flags for Rgraphviz])
AC_MSG_NOTICE([   PKG_CFLAGS=${PKG_CFLAGS}])
AC_SUBST(PKG_CFLAGS)
AC_MSG_NOTICE([   PKG_LIBS=${PKG_LIBS}])
AC_SUBST(PKG_LIBS)
AC_MSG_NOTICE([   GVIZ_DEFS=${GVIZ_DEFS}])
AC_SUBST(GVIZ_DEFS)
AC_MSG_NOTICE([Compiling using Graphviz version: '${GRAPHVIZ_VERSION}'.])
AC_MSG_NOTICE([Using bundled Graphviz: '${GRAPHVIZ_BUNDLED}'.])
AC_CONFIG_FILES([R/graphviz_build_version.R])
AC_SUBST(GRAPHVIZ_VERSION)
AC_SUBST(GRAPHVIZ_BUNDLED)
AC_CONFIG_FILES([src/Makevars])

AC_OUTPUT
