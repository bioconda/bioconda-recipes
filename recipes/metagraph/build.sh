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
    # GitHub archives extract to metagraph-{full-commit-hash}/
    if [[ "${SOURCE_DIR}" =~ metagraph-([a-f0-9]{40})$ ]]; then
        COMMIT_HASH="${BASH_REMATCH[1]}"
    elif [[ "$(basename ${SOURCE_DIR})" =~ metagraph-([a-f0-9]{40})$ ]]; then
        COMMIT_HASH="${BASH_REMATCH[1]}"
    else
        # Default commit hash from meta.yaml (should match the tarball)
        COMMIT_HASH="cc7cc94948c77094e36fd97c94490f0be003e592"
    fi
    
    # Initialize git repo if not already one
    if [ ! -d ".git" ]; then
        git init
        # Configure git user (required for commits)
        git config user.name "Conda Build"
        git config user.email "conda@build.local"
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
    
    # Fix .gitmodules paths - they have "metagraph/external-libraries/..." but we're at repo root
    # So we need to remove the "metagraph/" prefix from paths
    if [ -f ".gitmodules" ] && grep -q "path = metagraph/" .gitmodules; then
        # Deinitialize and remove all existing submodules first
        git submodule deinit --all -f 2>/dev/null || true
        # Remove all old submodule entries from .git/config
        # Use awk to remove sections starting with [submodule "metagraph/
        if [ -f ".git/config" ]; then
            awk '/^\[submodule "metagraph\// {skip=1; next} /^\[/ {skip=0} !skip' .git/config > .git/config.new && mv .git/config.new .git/config || true
        fi
        # Fix the paths in .gitmodules
        sed -i.bak 's|path = metagraph/|path = |g' .gitmodules
        # Clean up backup file
        rm -f .gitmodules.bak
        # Remove any existing .git/modules entries for old paths
        rm -rf .git/modules/metagraph 2>/dev/null || true
        # Sync submodule URLs with the corrected .gitmodules
        git submodule sync 2>/dev/null || true
    fi
    
    # Now we can use git submodule commands to get the correct versions
    git submodule update --init --recursive
    
    popd
    
    # Verify SOURCE_DIR is still valid after git operations
    # (git checkout doesn't change directory structure, so SOURCE_DIR should still be correct)
    if [ ! -f "${SOURCE_DIR}/CMakeLists.txt" ]; then
        # Fallback: try to find CMakeLists.txt
        FOUND_DIR=$(find . -maxdepth 3 -name "CMakeLists.txt" -type f | grep -v ".git" | head -1 | xargs dirname)
        if [ -n "${FOUND_DIR}" ] && [ -f "${FOUND_DIR}/CMakeLists.txt" ]; then
            SOURCE_DIR="${FOUND_DIR}"
        fi
    fi
fi

# Verify SOURCE_DIR is correct before proceeding
if [ ! -f "${SOURCE_DIR}/CMakeLists.txt" ]; then
    echo "Error: Could not find CMakeLists.txt at ${SOURCE_DIR}/CMakeLists.txt"
    echo "Current directory: $(pwd)"
    echo "SOURCE_DIR: ${SOURCE_DIR}"
    ls -la
    if [ -d "${SOURCE_DIR}" ]; then
        echo "Contents of ${SOURCE_DIR}:"
        ls -la "${SOURCE_DIR}" | head -20
    fi
    exit 1
fi

sed -i.bak 's|Boost_USE_STATIC_LIBS ON|Boost_USE_STATIC_LIBS OFF|' ${SOURCE_DIR}/CMakeLists.txt
rm -f ${SOURCE_DIR}/CMakeLists.txt.bak

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
