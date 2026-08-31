#!/bin/bash
set -e  # exit when any command fails

export CXXFLAGS="${CXXFLAGS-} -D_LIBCPP_ENABLE_CXX17_REMOVED_FEATURES"

echo -e "\n### INSTALLING PuMA GUI ###\n"
# The C++ library the GUI links against comes from the puma package in the host
# environment, so BUILD_PREFIX and INSTALL_PREFIX both point at the prefix.
cd "$SRC_DIR"/gui/build
# workarounds for openGL and g++ on linux
if [ "$(uname)" != "Darwin" ]; then
      # libGL comes from the libgl-devel host package, which installs into the
      # prefix.
      echo "QMAKE_LIBS_OPENGL=${PREFIX}/lib/libGL.so" >> pumaGUI.pro
      # pumaGUI.pro builds with qmake's linux-g++ spec, which invokes a bare
      # "g++", so a link to the conda compiler goes ahead of it on PATH. GXX
      # holds a command name, so resolve it to a path before linking to it.
      ln -sf "$(command -v "${GXX}")" g++
      export PATH="${PWD}:${PATH}"
fi
qmake \
      BUILD_PREFIX=$PREFIX \
      INSTALL_PREFIX=$PREFIX
make -j$CPU_COUNT
make install

echo -e "\n### END OF INSTALLATION ###\n"
