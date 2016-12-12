mkdir -pv $PREFIX/bin ${PREFIX}/share/man/man1
make
cp swarm.1 ${PREFIX}/share/man/man1
cp swarm_manual.pdf ${PREFIX}/share
if [[ "${PY_VER}" =~ 3 ]]
then
	2to3 -w -n scripts/*
fi
cp {swarm,scripts/amplicon_contingency_table.py,scripts/swarm_breaker.py} $PREFIX/bin
