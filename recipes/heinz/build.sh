mkdir build
cd build

cmake \
-DLIBLEMON_ROOT=${PREFIX} \
-DCPLEX_INC_DIR=${SRC_DIR}/IBM/cplex/include/ \
-DCPLEX_LIB_DIR=${SRC_DIR}/IBM/cplex/lib/x86-64_linux/static_pic \
-DCONCERT_LIB_DIR=${SRC_DIR}/IBM/concert/lib/x86-64_linux/static_pic \
-DCONCERT_INC_DIR=${SRC_DIR}/IBM/concert/include/ ..

make

chmod +x heinz
mkdir -p "${PREFIX}/bin"
mv heinz "${PREFIX}/bin/"
