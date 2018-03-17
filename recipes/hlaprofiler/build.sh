cp -r bin $PREFIX

mkdir -p $PREFIX/usr/local/share/
cp -r test $PREFIX/usr/local/share/hlaprofiler_tests


chmod +x $PREFIX/bin/HLAProfiler.pl 
chmod +x $PREFIX/bin/modules/*.pm 
