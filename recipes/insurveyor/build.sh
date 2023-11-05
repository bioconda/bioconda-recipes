set -x

${CXX} ${CPPFLAGS} ${CXXFLAGS} ${LDFLAGS} reads_categorizer.cpp -o reads_categorizer -pthread -lhts
${CXX} ${CPPFLAGS} ${CXXFLAGS} ${LDFLAGS} clip_consensus_builder.cpp -o clip_consensus_builder -pthread -lhts
${CXX} ${CPPFLAGS} ${CXXFLAGS} ${LDFLAGS} libs/ssw.c libs/ssw_cpp.cpp call_insertions.cpp -o call_insertions -pthread -lhts
${CXX} ${CPPFLAGS} ${CXXFLAGS} ${LDFLAGS} libs/ssw.c libs/ssw_cpp.cpp dc_remapper.cpp -o dc_remapper -pthread -lhts
${CXX} ${CPPFLAGS} ${CXXFLAGS} ${LDFLAGS} add_filtering_info.cpp -o add_filtering_info -pthread -lhts
${CXX} ${CPPFLAGS} ${CXXFLAGS} ${LDFLAGS} filter.cpp -o filter -pthread -lhts
${CXX} ${CPPFLAGS} ${CXXFLAGS} ${LDFLAGS} normalise.cpp -o normalise -pthread -lhts

cp reads_categorizer $PREFIX/bin/
cp clip_consensus_builder $PREFIX/bin/
cp call_insertions $PREFIX/bin/
cp dc_remapper $PREFIX/bin/
cp add_filtering_info $PREFIX/bin/
cp filter $PREFIX/bin/
cp normalise $PREFIX/bin/

cp insurveyor.py $PREFIX/bin/
cp random_pos_generator.py $PREFIX/bin/
