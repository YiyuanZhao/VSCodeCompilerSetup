# VSCodeCompilerSetup

## Brief Summary

This repository is created to synchronize `Run and Debug` tab for any Ubuntu OS. Everyone will be able to compile and debug C/Fortran codes with pressing `F5` button.

## Requirements

 - Ubuntu (apt required in setup)
 - Compiler for C/C++/Fortran. We use gcc/g++/gfortran/icc/icpc/ifort to build configuration file (launch.json and task.json).

## Configuration Details

Default task.json and launch.json created for vscode are configured with `gcc`, `g++`, `gfortran`, `icc`, `icpc`, `ifort` if each compiler is properly installed.

The GNU compiler (`gcc/g++/gfortran`) are linked to the library `blas`, `lapack`.       
The Intel compiler (`icc/icpc/ifort`) are linked to the library `mkl`.

Both compiler enables `openmp` flag for Openmp programming. Configurations with suffix `Debug` are compiled with flag `-g`, `-O0` to enable debug info and disable CPU out of order feature for debugging. Configurations with suffix `Release` are compiled with flag `-O2` to enable optimization.

## Usage

 ```shell
cd ~
git clone git@github.com:YiyuanZhao/vscodeCompilerSettings.git
cd vscodeCompilerSettings
./install.sh
 ```

 And it's done!

## Validate installation

Validation of this setup can be performed using helloworld code written in C/Fortran. Validation could be performed using following instruction"

 - Open proper file in `vscodeCompilerSettings/testing/baseTest` in VSCode. (e.g. `helloworld.c`)
 - Select proper Launch item in VSCode `RunAndDebug` tab. (e.g. press `Ctrl + Shift + D` and then select `gcc run active file (Debug)`).
 - Add a breakpoint in the code. (e.g. at line 4).
 - Press `F5`.
 - Check whether the code is compiled and run properly. The execution should stop at breakpoint depending on your settings.
 - Open proper file in `vscodeCompilerSettings/testing/externLibLinkTest` in VSCode. (e.g. `lapacke_test.c`) and repeat validation procedure.