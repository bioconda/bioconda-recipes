set -x

${CXX} ${CPPFLAGS} ${CXXFLAGS} ${LDFLAGS} reads_categorizer.cpp -o reads_categorizer -pthread -lhts
${CXX} ${CPPFLAGS} ${CXXFLAGS} ${LDFLAGS} libs/ssw.c libs/ssw_cpp.cpp clip_consensus_builder.cpp -o clip_consensus_builder -pthread -lhts
${CXX} ${CPPFLAGS} ${CXXFLAGS} ${LDFLAGS} merge_identical_calls.cpp -o merge_identical_calls -pthread -lhts
${CXX} ${CPPFLAGS} ${CXXFLAGS} -fpermissive ${LDFLAGS} libs/ssw.c libs/ssw_cpp.cpp libs/kdtree.c dp_clusterer.cpp -o dp_clusterer -pthread -lhts
${CXX} ${CPPFLAGS} ${CXXFLAGS} ${LDFLAGS} normalise.cpp -o normalise -pthread -lhts

cp reads_categorizer $PREFIX/bin/
cp clip_consensus_builder $PREFIX/bin/
cp call_insertions $PREFIX/bin/
cp dc_remapper $PREFIX/bin/
cp add_filtering_info $PREFIX/bin/
cp filter $PREFIX/bin/
cp normalise $PREFIX/bin/

cp survindel2.py $PREFIX/bin/
cp random_pos_generator.py $PREFIX/bin/
cp train_classifier.py $PREFIX/bin/survindel2_train_classifier.py
cp run_classifier.py $PREFIX/bin/survindel2_run_classifier.py
cp features.py $PREFIX/bin/features.py
