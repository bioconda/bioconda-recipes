#!/bin/bash
set +ex
export USE_CYTHON=True
export PERFORMING_CONDA_BUILD=True
export LIBRARY_PATH="${CONDA_PREFIX}/lib"
export LD_LIBRARY_PATH=${LIBRARY_PATH}:${LD_LIBRARY_PATH}
export CPLUS_INCLUDE_PATH="${CONDA_PREFIX}/include"

if [[ "$(uname -s)" == "Linux" ]];
then
  which x86_64-conda-linux-gnu-gcc
  x86_64-conda-linux-gnu-gcc -v
  x86_64-conda-linux-gnu-g++ -v
else
  which clang
  clang -v
fi

if [[ "$(uname -s)" == "Linux" ]];
then
  echo "====find crt1.o==="
  find ${CONDA_PREFIX} -name crt1.o

  echo "====list lib64===="
  echo ${CONDA_PREFIX}/x86_64-conda-linux-gnu/sysroot/usr/lib64
  ls -l ${CONDA_PREFIX}/x86_64-conda-linux-gnu/sysroot/usr/lib64/crt*

  echo "====Patching install_hpc_sdk script==="
  # the script in this version needs patching
  cat >script.patch <<EOF
diff --git a/scripts/install_hpc_sdk.sh.1 b/scripts/install_hpc_sdk.sh
index 53fadfe..2672c88 100755
--- a/scripts/install_hpc_sdk.sh.1
+++ b/scripts/install_hpc_sdk.sh
@@ -44,7 +44,11 @@ sed -i -e "s#PATH=/#PATH=\$PWD/conda_nv_bins:/#g" \\
   nvhpc_*/install_components/*/*/compilers/bin/makelocalrc
 sed -i -e "s#PATH=/#PATH=\$PWD/conda_nv_bins:/#g" \\
   nvhpc_*/install_components/install_cuda
-
+# and the right libraries
+sed -i -e "s#-f /usr/lib/x86_64-linux-gnu#-f \${CONDA_PREFIX}/x86_64-conda-linux-gnu/sysroot/usr/lib64#g" \\
+  nvhpc_*/install_components/*/*/compilers/bin/makelocalrc
+sed -i -e "s#DEFSTDOBJDIR=/usr/lib/x86_64-linux-gnu#DEFSTDOBJDIR=\${CONDA_PREFIX}/x86_64-conda-linux-gnu/sysroot/usr/lib64#g" \\
+  nvhpc_*/install_components/*/*/compilers/bin/makelocalrc
 
 export NVHPC_INSTALL_DIR=$PWD/hpc_sdk
 export NVHPC_SILENT=true
EOF

  patch -p1 <script.patch 
  echo "====check makelocalrc==="
  grep -A5 nvhpc_*/install_components/Linux_x86_64/21.7/compilers/bin/makelocalrc
  echo "====installing===="
  bash -x ./scripts/install_hpc_sdk.sh
  echo "====localrc===="
  cat less hpc_sdk/*/*/compilers/bin/localrc
  echo "===="
  source setup_nv_h5.sh
fi

pushd sucpp
make main
make api
make test
./test_su
popd

$PYTHON -m pip install --no-deps --ignore-installed .
