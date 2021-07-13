tar -zxvf "seecer.tar.gz"
mkdir -p "${PREFIX}/bin"
ln -s "seecer/SEECER/bin/run_seecer.sh" "${PREFIX}/bin/run_seecer.sh"
echo "${PREFIX}/bin"
#mkdir -p "$PREFIX/bin"

#ln -s build/bin/ORNA "$PREFIX/bin"
