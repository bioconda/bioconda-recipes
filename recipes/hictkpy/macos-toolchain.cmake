# https://conda-forge.org/docs/maintainer/knowledge_base/#newer-c-features-with-old-sdk
add_compile_definitions(_LIBCPP_DISABLE_AVAILABILITY)

set(CMAKE_OSX_SYSROOT $ENV{CONDA_BUILD_SYSROOT})
set(CMAKE_FIND_FRAMEWORK NEVER)
set(CMAKE_FIND_APPBUNDLE NEVER)

# WARNING: Target "_hictkpy" has runtime paths which cannot be changed during
# install.  To change runtime paths, OS X version 10.6 or newer is required.
# Therefore, runtime paths will not be changed when installing.
# CMAKE_BUILD_WITH_INSTALL_RPATH may be used to work around this limitation.
set(CMAKE_BUILD_WITH_INSTALL_RPATH ON)
