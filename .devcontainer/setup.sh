#!/bin/sh

# print versions
dmd --version
ldc2 --version
dub --version

# fetch project dependencies and build
dub fetch
dub build