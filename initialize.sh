#!/bin/sh
LLVM_COMMIT="$(cat llvm-release.txt)"
[ ! -f "$LLVM_COMMIT.tar.gz" ] && curl -O -L https://github.com/llvm/llvm-project/archive/$LLVM_COMMIT.tar.gz
[ "$(shasum -a 512 "$LLVM_COMMIT".tar.gz)" != "$(cat checksum.txt)" ] && exit 1
mkdir final
tar -xzf "$LLVM_COMMIT".tar.gz
mv llvm-project-"$LLVM_COMMIT"/ final/llvm-project
patch -p1 -R -d final/llvm-project < 4dec62f4d4a0a496a8067e283bf66897fbf6e598.patch
