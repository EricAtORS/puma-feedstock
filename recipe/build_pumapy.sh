#!/bin/bash
set -e  # exit when any command fails

# TexGen is GPL-2.0-or-later while the rest of PuMA is NASA-1.3, so it is only
# built into the gpl variant of this package. pumapy imports it inside a
# try/except and carries on without it, so the default build stays usable.
if [ "${PUMA_LICENSE_FAMILY}" = "gpl" ]; then
    echo -e "\n### INSTALLING TexGen ###\n"
    # TexGen is vendored and self-contained: it links nothing outside libstdc++,
    # and the python module it installs is what pumapy imports as TexGen.Core.
    cd "$SRC_DIR"/install/TexGen
    mkdir -p bin
    cd bin
    PY_VERSION="$(python -c 'import sys; print(sys.version_info[1])')"
    if [ $PY_VERSION -le 7 ]; then
        PY_VERSION="${PY_VERSION}m"
    fi
    # TexGen predates C++11 and still derives functors from std::binary_function,
    # which C++17 removed. Its CMakeLists requests no standard at all, so without
    # this it inherits the compiler default and fails to compile against libc++.
    cmake ${CMAKE_ARGS} -D BUILD_PYTHON_INTERFACE=ON \
          -D CMAKE_CXX_STANDARD=14 \
          -D CMAKE_CXX_STANDARD_REQUIRED=ON \
          -D CMAKE_CXX_EXTENSIONS=OFF \
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
fi


echo -e "\n### INSTALLING pumapy ###\n"
cd "$SRC_DIR"
$PYTHON setup.py install --single-version-externally-managed --record=record.txt

echo -e "\n### END OF INSTALLATION ###\n"
