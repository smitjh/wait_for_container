#!/bin/sh

# Expects musl and upx to be installed. 
export PATH=$PATH:/usr/local/musl/bin
nimble build --gcc.exe:musl-gcc --gcc.linkerexe:musl-gcc --passL:-static --opt:size -d:release
strip -s wait_for_container
upx --best wait_for_container
