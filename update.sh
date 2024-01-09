#!/usr/bin/env bash
set -euo pipefail

# TODO: ideally verify.sh runs this script with SPIRV_TOOLS_REV pinned,
# while update.sh updates this hash.
SPIRV_TOOLS_REV="c7affa1707b9c517ea028bf9070c97e6842a6749"

echo '----------------------------------------------------------------------------------------------------'
echo 'update.sh: note: merging upstream is not an automatic process, you must update SPIRV_TOOLS_REV in this'
echo 'script to the latest upstream revision from https://github.com/KhronosGroup/SPIRV-Tools'
echo '----------------------------------------------------------------------------------------------------'
git remote add upstream https://github.com/KhronosGroup/SPIRV-Tools || true
git fetch upstream
git merge $SPIRV_TOOLS_REV --strategy ours

# `git clone --depth 1` but at a specific revision
git_clone_rev() {
    repo=$1
    rev=$2
    dir=$3

    rm -rf "$dir"
    mkdir "$dir"
    pushd "$dir"
    git init -q
    git fetch "$repo" "$rev" --depth 1
    git checkout -q FETCH_HEAD
    popd
}

git_clone_rev https://github.com/KhronosGroup/SPIRV-Tools $SPIRV_TOOLS_REV upstream
pushd upstream
python3 utils/git-sync-deps
mkdir -p build && pushd build
cmake ..
# enough to make sure headers are generated
make & sleep 20; kill $!
popd
echo '----------------------------------------------------------------------------------------------------'
echo 'update.sh: note: terminating the build early just to collect headers, do not worry about the failure'
echo '----------------------------------------------------------------------------------------------------'
rm -rf include-generated
mkdir -p include-generated
find build -name "*.inc" -exec cp -r '{}' ../include-generated/ \;
popd
rm -rf upstream
