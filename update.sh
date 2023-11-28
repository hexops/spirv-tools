#!/usr/bin/env bash
set -euo pipefail

git clone https://github.com/KhronosGroup/SPIRV-Tools upstream --depth 1 || true
pushd upstream
python3 utils/git-sync-deps
mkdir -p build && pushd build
cmake ..
# enough to make sure headers are generated
timeout 20 make || true
popd
find build -name "*.inc" -exec cp -r '{}' ../include-generated/ \;
popd
rm -rf upstream

git remote add upstream https://github.com/KhronosGroup/SPIRV-Tools || true
git fetch upstream
git merge upstream/main --strategy ours