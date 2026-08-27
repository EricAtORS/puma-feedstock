setlocal EnableDelayedExpansion

echo ### INSTALLING PuMA C++ library ###
mkdir "%SRC_DIR%\install\cmake-build-release"
cd "%SRC_DIR%\install\cmake-build-release"
cmake %CMAKE_ARGS% -G "Ninja" ^
      -D CONDA_PREFIX="%PREFIX%" ^
      -D CMAKE_INSTALL_PREFIX="%PREFIX%" ^
      -D CMAKE_BUILD_TYPE=Release ^
      "%SRC_DIR%\cpp"
if errorlevel 1 exit 1
cmake --build . --config Release
if errorlevel 1 exit 1
cmake --install .
if errorlevel 1 exit 1
del "%PREFIX%\bin\pumaX_main.exe"

echo ### INSTALLING pumapy ###
cd "%SRC_DIR%"
%PYTHON% setup.py install --single-version-externally-managed --record record.txt
if errorlevel 1 exit 1
