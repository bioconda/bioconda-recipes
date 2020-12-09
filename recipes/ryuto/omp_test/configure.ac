AC_INIT([ttrans], [1.0])
AC_CONFIG_SRCDIR([src/omp_hello.cc])
AC_CONFIG_MACRO_DIR([m4])
AM_INIT_AUTOMAKE([subdir-objects])
AC_PROG_CXX

CXXFLAGS="$CXXFLAGS -O2"
#CXXFLAGS=" -ggdb"

AC_LANG([C++])

#openMP
AC_OPENMP
 
AX_CHECK_COMPILE_FLAG([-std=c++11], CXXFLAGS="$CXXFLAGS -std=c++11")

AC_ARG_ENABLE([mac], [AS_HELP_STRING([--enable-mac], [enable mac linkig])])

AS_IF([test "x$enable_mac" = xyes], [ CPPFLAGS="$CPPFLAGS -Xclang -fopenmp" LDFLAGS="$LDFLAGS -lomp"  ])

AC_CONFIG_FILES(Makefile src/Makefile)
AC_OUTPUT


