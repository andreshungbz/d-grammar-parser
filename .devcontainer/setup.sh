#!/bin/sh

# source DMD for bash, zsh, and the postCreationCommand shell
echo '. ~/dlang/dmd-*/activate' >> ~/.zshrc
echo '. ~/dlang/dmd-*/activate' >> ~/.bashrc
. ~/dlang/dmd-*/activate

# print versions
dmd --version
dub --version