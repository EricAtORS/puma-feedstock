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


echo -e "\n### INSTALLING TexGen ###\n"
cd "$SRC_DIR"/install/TexGen
mkdir -p bin
cd bin
PY_VERSION="$(python -c 'import sys; print(sys.version_info[1])')"
if [ $PY_VERSION -le 7 ]; then
    PY_VERSION="${PY_VERSION}m"
fi
cmake ${CMAKE_ARGS} -D BUILD_PYTHON_INTERFACE=ON \
      -D CMAKE_INSTALL_PREFIX=$PREFIX \
      -D PYTHON_INCLUDE_DIR="$PREFIX"/include/python3.$PY_VERSION \
      -D PYTHON_LIBRARY="$PREFIX"/lib/libpython3.$PY_VERSION$SHLIB_EXT \
      -D PYTHON_SITEPACKAGES_DIR="$SP_DIR" \
      -D BUILD_GUI=OFF \
      -D BUILD_RENDERER=OFF \
      -D CMAKE_MACOSX_RPATH=ON \
      -D CMAKE_INSTALL_RPATH_USE_LINK_PATH=ON \
      -D CMAKE_INSTALL_RPATH="$PREFIX"/lib \
      -D BUILD_SHARED_LIBS=OFF \
      ..
make -j$CPU_COUNT
make install


echo -e "\n### INSTALLING pumapy ###\n"
cd "$SRC_DIR"
$PYTHON setup.py install --single-version-externally-managed --record=record.txt


echo -e "\n### INSTALLING PuMA GUI ###\n"
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
