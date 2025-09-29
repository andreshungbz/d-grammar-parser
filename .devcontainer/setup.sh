#!/bin/sh

# print versions
dmd --version
dub --version

# fetch project dependencies and build
dub fetch
dub build