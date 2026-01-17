#!/bin/bash
LLVM_RELEASE="$(cat llvm-release.txt)"
if [ "$2" != "stage1" ]; then
    tar -xf build_directory.tar
fi
cp final/llvm-project/llvm/utils/release/test-release.sh .
patch -p1 < 0001-skip-tests.patch
patch -p1 < 0002-support-partitioned-builds.patch
patch -p1 < 0003-use-built-in-xz-compression.patch


# https://trac.macports.org/wiki/ProblemHotlist#clts16
sudo rm -rf /Library/Developer/CommandLineTools/usr/include/c++
sudo xcode-select --install

CONFIGURE_FLAGS=(
  -DLLVM_APPEND_VC_REV=OFF
  -DLLVM_ENABLE_TERMINFO=OFF
  -DLLVM_ENABLE_Z3_SOLVER=OFF
  -DCLANG_PLUGIN_SUPPORT=OFF
  -DCLANG_ENABLE_STATIC_ANALYZER=OFF
  -DCLANG_ENABLE_ARCMT=OFF
  -DLLVM_ENABLE_DIA_SDK=OFF
  -DLLVM_ENABLE_CURL=OFF
  -DLIBCLANG_BUILD_STATIC=ON
)

./test-release.sh \
    -release "$LLVM_RELEASE" \
    -final \
    -triple "$1"-apple-darwin21.0 \
    -no-checkout \
    -no-clang-tools \
    -no-test-suite \
    -no-openmp \
    -no-polly \
    -no-mlir \
    -no-flang \
    -no-compare-files \
    -configure-flags "${CONFIGURE_FLAGS[*]}" \
    -"$2"
if [ "$2" != "stage3" ]; then
    tar -cf build_directory.tar final
    exit 0
fi
_release_tag_version="$LLVM_RELEASE"-"$1"
[ "$(cat revision.txt)" -ne 0 ] && _release_tag_version="$_release_tag_version"-"$(cat revision.txt)"
echo "file_name=clang+llvm-$LLVM_RELEASE-$1-apple-darwin21.0.tar.xz" >> "$GITHUB_OUTPUT"
echo "release_tag_version=$_release_tag_version" >> "$GITHUB_OUTPUT"
printf 'SHA512 checksum:\n<code>' > github_release_text.md
printf '%s' "$(shasum -a 512 final/clang+llvm-"$LLVM_RELEASE"-"$1"-apple-darwin21.0.tar.xz | sed 's,final/,,' | sed 's, ,\&nbsp;,g')" >> github_release_text.md
printf '</code>\n' >> github_release_text.md
mkdir output
mv final/clang+llvm-"$LLVM_RELEASE"-"$1"-apple-darwin21.0.tar.xz output/
