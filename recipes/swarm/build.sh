mkdir -pv ${PREFIX}/bin ${PREFIX}/share/man/man1
sed -i.bak "s/-a //g" src/Makefile
make -C src CXX=${CXX}
cp bin/swarm ${PREFIX}/bin
cp man/swarm.1 ${PREFIX}/share/man/man1
cp man/swarm_manual.pdf ${PREFIX}/share
chmod +x scripts/*
cp scripts/* ${PREFIX}/bin
