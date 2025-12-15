#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -Wno-deprecated-declarations -Wno-attributes"

ARCH=$(uname -m)
OS=$(uname -s)

# Determine source directory - find directory containing CMakeLists.txt
# GitHub archive extracts to metagraph-{hash}/ which contains metagraph/ subdirectory
# So CMakeLists.txt is at metagraph-{hash}/metagraph/CMakeLists.txt
if [ -f "CMakeLists.txt" ]; then
    SOURCE_DIR="."
elif [ -d "metagraph" ] && [ -f "metagraph/CMakeLists.txt" ]; then
    # Either we're in metagraph-{hash}/ and metagraph/ is a subdirectory, or conda renamed it
    SOURCE_DIR="metagraph"
elif ls -d metagraph-* 2>/dev/null | head -1 | grep -q .; then
    # GitHub archive extracts to metagraph-{hash}/
    ARCHIVE_DIR=$(ls -d metagraph-* 2>/dev/null | head -1)
    if [ -f "${ARCHIVE_DIR}/metagraph/CMakeLists.txt" ]; then
        # CMakeLists.txt is in metagraph-{hash}/metagraph/
        SOURCE_DIR="${ARCHIVE_DIR}/metagraph"
    elif [ -f "${ARCHIVE_DIR}/CMakeLists.txt" ]; then
        # CMakeLists.txt is directly in metagraph-{hash}/ (unlikely but handle it)
        SOURCE_DIR="${ARCHIVE_DIR}"
    else
        SOURCE_DIR="."
    fi
else
    SOURCE_DIR="."
fi

# Verify we found the right directory
if [ ! -f "${SOURCE_DIR}/CMakeLists.txt" ]; then
    echo "Error: Could not find CMakeLists.txt. Current directory: $(pwd)"
    echo "SOURCE_DIR: ${SOURCE_DIR}"
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
    # We need to initialize git at the archive root (where .gitmodules is), not in SOURCE_DIR
    # If SOURCE_DIR is metagraph-{hash}/metagraph/, then archive root is metagraph-{hash}/
    if [[ "${SOURCE_DIR}" == */metagraph ]]; then
        # SOURCE_DIR is something like metagraph-{hash}/metagraph/, archive root is one level up
        ARCHIVE_ROOT=$(dirname "${SOURCE_DIR}")
    elif [[ "${SOURCE_DIR}" =~ ^metagraph- ]]; then
        # SOURCE_DIR is metagraph-{hash}/, that's the archive root
        ARCHIVE_ROOT="${SOURCE_DIR}"
    else
        # SOURCE_DIR is just "metagraph" or ".", try to find archive root
        if [ -d "metagraph" ] && [ -f "metagraph/CMakeLists.txt" ]; then
            # We're at archive root, metagraph/ is subdirectory
            ARCHIVE_ROOT="."
        else
            # Assume SOURCE_DIR is archive root
            ARCHIVE_ROOT="${SOURCE_DIR}"
        fi
    fi
    
    echo "Initializing git repository at archive root to fetch submodules..."
    pushd ${ARCHIVE_ROOT}
    
    # Try to extract commit hash from directory name (metagraph-{hash}/) or use default
    # GitHub archives extract to metagraph-{full-commit-hash}/
    if [[ "${ARCHIVE_ROOT}" =~ metagraph-([a-f0-9]{40})$ ]] || [[ "${ARCHIVE_ROOT}" =~ metagraph-([a-f0-9]{40})/ ]]; then
        COMMIT_HASH="${BASH_REMATCH[1]}"
    elif [[ "${SOURCE_DIR}" =~ metagraph-([a-f0-9]{40})/metagraph$ ]]; then
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
    
    # We're at the archive root, so .gitmodules paths like "metagraph/external-libraries/..." are correct
    # No need to fix paths - git will create submodules at the correct locations
    echo "Initializing submodules from archive root: $(pwd)"
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
