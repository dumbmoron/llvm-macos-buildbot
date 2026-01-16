#!/bin/sh
LLVM_COMMIT="$(cat llvm-release.txt)"
[ ! -f "$LLVM_COMMIT.tar.gz" ] && curl -O -L https://github.com/llvm/llvm-project/archive/$LLVM_COMMIT.tar.gz
[ "$(shasum -a 512 "$LLVM_COMMIT".tar.gz)" != "$(cat checksum.txt)" ] && exit 1
mkdir final
tar -xzf "$LLVM_COMMIT".tar.gz
mv llvm-project-"$LLVM_COMMIT"/ final/llvm-project
