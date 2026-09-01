#!/bin/bash
set -e  # exit when any command fails

export CXXFLAGS="${CXXFLAGS-} -D_LIBCPP_ENABLE_CXX17_REMOVED_FEATURES"

echo -e "\n### INSTALLING PuMA C++ library ###\n"
cd install 
mkdir -p cmake-build-release
cd cmake-build-release
cmake ${CMAKE_ARGS} -D CONDA_PREFIX=$PREFIX \
      -D CMAKE_INSTALL_PREFIX=$PREFIX \
      "$SRC_DIR"/cpp
make -j$CPU_COUNT
make install
rm ${PREFIX}/bin/pumaX_main

echo -e "\n### END OF INSTALLATION ###\n"
