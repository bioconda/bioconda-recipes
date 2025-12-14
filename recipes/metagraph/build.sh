#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -Wno-deprecated-declarations -Wno-attributes"

ARCH=$(uname -m)
OS=$(uname -s)

# Determine source directory - find directory containing CMakeLists.txt
# Handles: git source (current dir), tarball with metagraph/ subdir, or GitHub archive (metagraph-{hash}/)
if [ -f "CMakeLists.txt" ]; then
    SOURCE_DIR="."
elif [ -d "metagraph" ] && [ -f "metagraph/CMakeLists.txt" ]; then
    SOURCE_DIR="metagraph"
elif ls -d metagraph-* 2>/dev/null | head -1 | xargs test -f 2>/dev/null; then
    # GitHub archive extracts to metagraph-{hash}/
    SOURCE_DIR=$(ls -d metagraph-* 2>/dev/null | head -1)
else
    SOURCE_DIR="."
fi

# Verify we found the right directory
if [ ! -f "${SOURCE_DIR}/CMakeLists.txt" ]; then
    echo "Error: Could not find CMakeLists.txt. Current directory: $(pwd)"
    ls -la
    exit 1
fi

# Initialize submodules if we're in a git repository (for local testing with git_url)
if [ -d "${SOURCE_DIR}/.git" ]; then
    pushd ${SOURCE_DIR}
    git submodule update --init --recursive
    popd
else
    # GitHub archive doesn't include submodules, so initialize git repo and use submodule commands
    echo "Initializing git repository to fetch submodules..."
    pushd ${SOURCE_DIR}
    
    # Try to extract commit hash from directory name (metagraph-{hash}/) or use default
    if [[ "${SOURCE_DIR}" =~ metagraph-([a-f0-9]{40}) ]]; then
        COMMIT_HASH="${BASH_REMATCH[1]}"
    else
        # Default commit hash from meta.yaml (should match the tarball)
        COMMIT_HASH="cc7cc94948c77094e36fd97c94490f0be003e592"
    fi
    
    # Initialize git repo if not already one
    if [ ! -d ".git" ]; then
        git init
        git remote add origin https://github.com/ratschlab/metagraph.git 2>/dev/null || \
            git remote set-url origin https://github.com/ratschlab/metagraph.git
        # Fetch only the specific commit we need
        git fetch --depth 1 origin ${COMMIT_HASH}
        # Add all existing files to git to track them, then checkout will work
        git add -A
        git commit -m "Temporary commit" || true
        # Now checkout the correct commit, which will overwrite with git version
        git checkout -f ${COMMIT_HASH}
    fi
    
    # Now we can use git submodule commands to get the correct versions
    git submodule update --init --recursive
    
    popd
fi

# set version manually for htscodecs
echo '#define HTSCODECS_VERSION_TEXT "1.6.4"' > ${SOURCE_DIR}/external-libraries/htslib/htscodecs/htscodecs/version.h

sed -i.bak 's|Boost_USE_STATIC_LIBS ON|Boost_USE_STATIC_LIBS OFF|' ${SOURCE_DIR}/CMakeLists.txt

[[ ! -d ${SOURCE_DIR}/build ]] || rm -rf ${SOURCE_DIR}/build
mkdir -p ${SOURCE_DIR}/build
cd ${SOURCE_DIR}/build

# needed for setting up python based integration test environment
export PIP_NO_INDEX=False

CMAKE_PARAMS="-DCMAKE_BUILD_TYPE=Release \
            -DBOOST_ROOT=${PREFIX} \
            -DCMAKE_INSTALL_LIBDIR=${PREFIX}/lib \
            -DCMAKE_INSTALL_PREFIX=${PREFIX} \
            -DCMAKE_SKIP_INSTALL_ALL_DEPENDENCY=1 \
            -DBUILD_KMC=OFF \
            "

cmake -S .. -B . ${CMAKE_PARAMS}

BUILD_CMD="make metagraph -j${CPU_COUNT}"

${BUILD_CMD}

make install

### Make Protein binary version

make clean

cmake -S .. -B . ${CMAKE_PARAMS} -DCMAKE_DBG_ALPHABET=Protein

${BUILD_CMD}

make install

### Adding symlink to default DNA binary version
pushd ${PREFIX}/bin
chmod 0755 metagraph_DNA
ln -sf metagraph_DNA metagraph
popd
