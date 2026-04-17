#!/bin/bash

${CXX} --std=c++17 scripts/count_lineages_country.cpp -o scripts/count_lineages_country -lstdc++ -lboost_regex ${CXXFLAGS} ${LDFLAGS}

# Define the target directory
TARGET_DIR=$PREFIX/share/corona_lineage_dynamics

# Create the target directory
mkdir -p $TARGET_DIR

# Copy the entire repository to the target directory
cp -r * $TARGET_DIR/

# Create the proxy script in $PREFIX/bin
mkdir -p $PREFIX/bin
cat > $PREFIX/bin/corona_lineage_dynamics <<EOF 
#!/bin/bash
bash $TARGET_DIR/SDPlots_lineages_local.sh "\$@"
EOF

# Make the proxy script executable
chmod +x $PREFIX/bin/corona_lineage_dynamics

