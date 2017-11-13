mkdir -pv ${PREFIX}/bin ${PREFIX}/share/man/man1
make -C src
cp bin/swarm ${PREFIX}/bin
cp man/swarm.1 ${PREFIX}/share/man/man1
cp man/swarm_manual.pdf ${PREFIX}/share
if [[ "${PY_VER}" =~ 3 ]]
then
	2to3 -w -n scripts/*
fi
chmod +x scripts/*
cp scripts/* ${PREFIX}/bin
