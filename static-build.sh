#!/bin/sh

# Build a statically linked executable using musl.
# This should produce a file that should be portable to any linux system.

# Expects musl to be installed to /usr/local/musl
export PATH=$PATH:/usr/local/musl/bin
nimble build --gcc.exe:musl-gcc --gcc.linkerexe:musl-gcc --passL:-static --opt:size -d:release
strip -s wait_for_container

if [ "$(which upx)" != "" ] ; then
    upx --best wait_for_container
else
    echo "Upx not installed. Consider installing it to further reduce binary size"
    echo "See: https://upx.github.io/"
fi
