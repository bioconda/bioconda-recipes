if (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
  message(STATUS "Including toolchain file for Darwin")
  include($ENV{RECIPE_DIR}/macos-toolchain.cmake)
else()
  message(STATUS "Including toolchain file for Linux")
  include($ENV{RECIPE_DIR}/linux-toolchain.cmake)
endif()

include_directories($ENV{PREFIX}/include)
link_directories($ENV{PREFIX}/lib)

# help CMake find the tools required to enable LTO
find_program(LLVM_AR_PATH llvm-ar REQUIRED)
find_program(LLVM_RANLIB_PATH llvm-ranlib REQUIRED)

set(CMAKE_C_COMPILER $ENV{CC})
set(CMAKE_C_COMPILER_AR ${LLVM_AR_PATH})
set(CMAKE_C_COMPILER_RANLIB ${LLVM_RANLIB_PATH})
set(CMAKE_C_STANDARD 23)
set(CMAKE_CXX_COMPILER $ENV{CXX})
set(CMAKE_CXX_COMPILER_AR ${LLVM_AR_PATH})
set(CMAKE_CXX_COMPILER_RANLIB ${LLVM_RANLIB_PATH})
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_LINKER_TYPE LLD)

execute_process(
  COMMAND
    "$ENV{PYTHON}" "-c" "import sysconfig; print(sysconfig.get_path('include'))"
  OUTPUT_VARIABLE Python_INCLUDE_DIR
  COMMAND_ERROR_IS_FATAL ANY
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

execute_process(
  COMMAND
    "$ENV{PYTHON}" "-c" "import numpy; print(numpy.get_include())"
  OUTPUT_VARIABLE Python_NumPy_INCLUDE_DIR
  COMMAND_ERROR_IS_FATAL ANY
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

# See https://github.com/conda-forge/conda-forge.github.io/pull/2321
set(Python_EXECUTABLE $ENV{PYTHON})
set(Python_INCLUDE_DIR ${Python_INCLUDE_DIR})
set(Python_NumPy_INCLUDE_DIR ${Python_NumPy_INCLUDE_DIR})
set(Python3_EXECUTABLE $ENV{PYTHON})
set(Python3_INCLUDE_DIR ${Python_INCLUDE_DIR})
set(Python3_NumPy_INCLUDE_DIR ${Python_NumPy_INCLUDE_DIR})
