#!/usr/bin/env bash
set -euo pipefail

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

SPIRV_TOOLS_REV=f4a73dd7a0cadfa9a9ea384b609e0e6a2cb71f5b
git_clone_rev https://github.com/KhronosGroup/SPIRV-Tools $SPIRV_TOOLS_REV upstream
pushd upstream
python3 utils/git-sync-deps
mkdir -p build && pushd build
cmake ..
# enough to make sure headers are generated
timeout 20 make || true
popd
rm -rf include-generated
mkdir -p include-generated
find build -name "*.inc" -exec cp -r '{}' ../include-generated/ \;
popd
rm -rf upstream

git remote add upstream https://github.com/KhronosGroup/SPIRV-Tools || true
git fetch upstream
git merge upstream/main --strategy ours