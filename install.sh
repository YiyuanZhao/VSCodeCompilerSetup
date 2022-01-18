#!/bin/bash
# Designed for Ubuntu Only because of usage of command "apt install"
cat <<EOF
Checking Available compiler
--------------------------------------------
gcc:        $( if [[ -n $(which gcc) ]]; then echo $(which gcc); else echo "Not found"; fi)
g++:        $( if [[ -n $(which g++) ]]; then echo $(which g++); else echo "Not found"; fi)
gfortran:   $( if [[ -n $(which gfortran) ]]; then echo $(which gfortran); else echo "Not found"; fi)
icc:        $( if [[ -n $(which icc) ]]; then echo $(which icc); else echo "Not found"; fi)
icpc:        $( if [[ -n $(which icpc) ]]; then echo $(which icpc); else echo "Not found"; fi)
ifort:      $( if [[ -n $(which ifort) ]]; then echo $(which ifort); else echo "Not found"; fi)
--------------------------------------------

EOF

if [[ ! -e ./.vscode/ ]]
then
    mkdir ./.vscode
fi

if [[ -e "./.vscode/launch.json" || -e "./.vscode/tasks.json" ]]
then
    cat <<EOF
--------------------------------------------
Remove Previous Configuration Settings
--------------------------------------------
Removing Current Run&Debug Configuration File?
Type 'y' or 'ENTER' to continue, or type 'n' to archive them
EOF
    read flag
    if [[ -n $flag && ( $flag = 'n' || $flag = 'N') ]]
    then
        echo "Archive Previous Configuration File"
        mv ./.vscode/launch.json ./.vscode/launchArchive.json
        mv ./.vscode/tasks.json ./.vscode/tasksArchive.json
        cat </dev/null >./.vscode/launch.json >./.vscode/tasks.json
    else
        echo "Remove Previous Configuration File"
        cat </dev/null >./.vscode/launch.json >./.vscode/tasks.json
    fi
fi

if [[ -n $(ldconfig -p | grep libblas) ]]
then
    installBLAS=$(ldconfig -p | grep libblas | head -1)
else
    installBLAS="Not found"
fi

if [[ -n $(ldconfig -p | grep liblapack) ]]
then
    installLAPACK=$(ldconfig -p | grep liblapack.so | head -1)
else
    installLAPACK="Not found"
fi

if [[ -n $(ldconfig -p | grep liblapacke) ]]
then
    installLAPACKE=$(ldconfig -p | grep liblapacke | head -1)
else
    installLAPACKE="Not found"
fi

if [[ -n $(which gdb) ]]
then
    installGdb=$(which gdb)
else
    installGdb="Not found"
fi

cat <<EOF
-----------------------------------------------------------------
Checking Linear Algebra Libraries (BLAS and LAPACK) and Debugger
-----------------------------------------------------------------
Checking BLAS:          $installBLAS
Checking LAPACK:        $installLAPACK
Checking LAPACKE:       $installLAPACKE
Checking Debugger(gdb): $installGdb

Checking Complete.
The missing package will be installed.
EOF

if [[ $installBLAS = "Not found" ]] || [[ $installLAPACK = "Not found" ]] || [[ $installLAPACKE = "Not found" ]]
then
    sudo apt-get update
fi

if [[ $installBLAS = "Not found" ]]
then
    echo "Executing: sudo apt install -y libblas-dev"
    sudo apt install -y libblas-dev
fi

if [[ $installLAPACK = "Not found" ]]
then
    echo "Executing: sudo apt install -y liblapack-dev"
    sudo apt install -y liblapack-dev
fi

if [[ $installLAPACKE = "Not found" ]]
then
    echo "Executing: sudo apt install -y liblapacke-dev"
    sudo apt install -y liblapacke-dev
fi

if [[ $installGdb = "Not found" ]]
then
    echo "Executing: sudo apt install -y gdb"
    sudo apt install -y gdb
fi

cat <<EOF


--------------------------------------------
Configuring tasks.json, launch.json
--------------------------------------------
EOF

cat >tasks.json <<EOF
{
    "version": "2.0.0",
    "tasks": [
EOF

if [[ -n $(which gcc) ]]
then
    cat >>tasks.json <<EOF
        {
            "type": "shell",
            "label": "gcc build active file (Debug)",
            "command": "$(which gcc)",
            "args": [
                "-g",
                "\${file}",
                "-o",
                "\${fileDirname}/\${fileBasenameNoExtension}",
                "-O0",
                "-Wall",
                "-fopenmp",
                "-static-libgfortran",
                "-fopenmp",
                "-lblas",
                "-llapacke"
            ],
            "options": {
                "cwd": "\${fileDirname}"
            },
            "problemMatcher": [
                "\$gcc"
            ],
            "group": "build"
        },
EOF
fi

if [[ -n $(which g++) ]]
then
    cat >>tasks.json <<EOF
        {
            "type": "shell",
            "label": "g++ build active file (Debug)",
            "command": "$(which g++)",
            "args": [
                "-g",
                "\${file}",
                "-o",
                "\${fileDirname}/\${fileBasenameNoExtension}",
                "-O0",
                "-Wall",
                "-fopenmp",
                "-static-libgfortran",
                "-fopenmp",
                "-lblas",
                "-llapacke"
            ],
            "options": {
                "cwd": "\${fileDirname}"
            },
            "problemMatcher": [
                "\$gcc"
            ],
            "group": "build"
        },
EOF
fi

if [[ -n $(which gfortran) ]]
then
    cat >>tasks.json <<EOF
        {
            "label": "gfortran build active file (Debug)",
            "command": "$(which gfortran)",
            "args": [
                "-g",
                "\${file}",
                "-o",
                "\${fileDirname}/\${fileBasenameNoExtension}",
                "-Wall",
                "-fopenmp",
                "-O0",
                "-static-libgcc",
                "-llapack",
                "-lblas"
            ],
            "problemMatcher": [],
            "group": "build",
            "options": {
                "cwd": "\${fileDirname}"
            }
        },
EOF
fi

if [[ -n $(which icc) ]]
then
    cat >>tasks.json <<EOF
        {
            "label": "icc build active file (Debug)",
            "command": "$(which icc)",
            "args": [
                "-g",
                "\${file}",
                "-o",
                "\${fileDirname}/\${fileBasenameNoExtension}",
                "-O0",
                "-mkl",
                "-qopenmp"
            ],
            "problemMatcher": [],
            "group": "build",
            "options": {
                "cwd": "\${fileDirname}"
            }
        },
EOF
fi

if [[ -n $(which icpc) ]]
then
    cat >>tasks.json <<EOF
        {
            "label": "icpc build active file (Debug)",
            "command": "$(which icpc)",
            "args": [
                "-g",
                "\${file}",
                "-o",
                "\${fileDirname}/\${fileBasenameNoExtension}",
                "-O0",
                "-mkl",
                "-qopenmp"
            ],
            "problemMatcher": [],
            "group": "build",
            "options": {
                "cwd": "\${fileDirname}"
            }
        },
EOF
fi

if [[ -n $(which ifort) ]]
then
    cat >>tasks.json <<EOF
        {
            "label": "ifort build active file (Debug)",
            "command": "$(which ifort)",
            "args": [
                "-g",
                "\${file}",
                "-o",
                "\${fileDirname}/\${fileBasenameNoExtension}",
                "-O0",
                "-mkl",
                "-qopenmp"
            ],
            "problemMatcher": [],
            "group": "build",
            "options": {
                "cwd": "\${fileDirname}"
            }
        },
EOF
fi

if [[ -n $(which gcc) ]]
then
    cat >>tasks.json <<EOF
        {
            "type": "shell",
            "label": "gcc build active file (Release)",
            "command": "$(which gcc)",
            "args": [
                "\${file}",
                "-o",
                "\${fileDirname}/\${fileBasenameNoExtension}",
                "-O2",
                "-Wall",
                "-fopenmp",
                "-static-libgfortran",
                "-fopenmp",
                "-lblas",
                "-llapacke"
            ],
            "options": {
                "cwd": "\${fileDirname}"
            },
            "problemMatcher": [
                "\$gcc"
            ],
            "group": "build"
        },
EOF
fi

if [[ -n $(which g++) ]]
then
    cat >>tasks.json <<EOF
        {
            "type": "shell",
            "label": "g++ build active file (Release)",
            "command": "$(which g++)",
            "args": [
                "\${file}",
                "-o",
                "\${fileDirname}/\${fileBasenameNoExtension}",
                "-O2",
                "-Wall",
                "-fopenmp",
                "-static-libgfortran",
                "-fopenmp",
                "-lblas",
                "-llapacke"
            ],
            "options": {
                "cwd": "\${fileDirname}"
            },
            "problemMatcher": [
                "\$gcc"
            ],
            "group": "build"
        },
EOF
fi

if [[ -n $(which gfortran) ]]
then
    cat >>tasks.json <<EOF
        {
            "label": "gfortran build active file (Release)",
            "command": "$(which gfortran)",
            "args": [
                "\${file}",
                "-o",
                "\${fileDirname}/\${fileBasenameNoExtension}",
                "-Wall",
                "-O2",
                "-fopenmp",
                "-static-libgcc",
                "-llapack",
                "-lblas"
            ],
            "problemMatcher": [],
            "group": "build",
            "options": {
                "cwd": "\${fileDirname}"
            }
        },
EOF
fi

if [[ -n $(which icc) ]]
then
    cat >>tasks.json <<EOF
        {
            "label": "icc build active file (Release)",
            "command": "$(which icc)",
            "args": [
                "\${file}",
                "-o",
                "\${fileDirname}/\${fileBasenameNoExtension}",
                "-Wall",
                "-O2",
                "-mkl",
                "-qopenmp"
            ],
            "problemMatcher": [],
            "group": "build",
            "options": {
                "cwd": "\${fileDirname}"
            }
        },
EOF
fi

if [[ -n $(which icpc) ]]
then
    cat >>tasks.json <<EOF
        {
            "label": "icpc build active file (Release)",
            "command": "$(which icpc)",
            "args": [
                "\${file}",
                "-o",
                "\${fileDirname}/\${fileBasenameNoExtension}",
                "-Wall",
                "-O2",
                "-mkl",
                "-qopenmp"
            ],
            "problemMatcher": [],
            "group": "build",
            "options": {
                "cwd": "\${fileDirname}"
            }
        },
EOF
fi

if [[ -n $(which ifort) ]]
then
    cat >>tasks.json <<EOF
        {
            "label": "ifort build active file (Release)",
            "command": "$(which ifort)",
            "args": [
                "\${file}",
                "-o",
                "\${fileDirname}/\${fileBasenameNoExtension}",
                "-O2",
                "-mkl",
                "-qopenmp"
            ],
            "problemMatcher": [],
            "group": "build",
            "options": {
                "cwd": "\${fileDirname}"
            }
        },
EOF
fi

cat >>tasks.json <<EOF
        {
            "label": "make command task",
            "command": "/bin/bash",
            "args": [
                "-c",
                "make clean; make",
            ],
            "problemMatcher": [],
            "group": "build",
            "options": {
                "cwd": "\${fileDirname}"
            }
        },
EOF

cat >>tasks.json <<EOF
    ]
}
EOF

echo "tasks.json Configured"

cat >launch.json <<EOF
{
  "version": "0.2.0",
  "configurations": [
EOF

if [[ -n $(which python) ]]
then
    cat >>launch.json <<EOF
    {
      "name": "Python: Run Current File",
      "type": "python",
      "request": "launch",
      "program": "\${file}",
      "console": "internalConsole",
      "cwd": "\${fileDirname}"
    },
EOF
fi

if [[ -n $(which gcc) ]]
then
    cat >>launch.json <<EOF
    {
      "name": "gcc run active file (Debug)",
      "type": "cppdbg",
      "request": "launch",
      "program": "\${fileDirname}/\${fileBasenameNoExtension}",
      "stopAtEntry": false,
      "cwd": "\${fileDirname}",
      "environment": [],
      "externalConsole": false,
      "MIMode": "gdb",
      "miDebuggerPath": "$(which gdb)",
      "setupCommands": [
        {
          "description": "Enable pretty-printing for gdb",
          "text": "-enable-pretty-printing",
          "ignoreFailures": true
        }
      ],
      "preLaunchTask": "gcc build active file (Debug)"
    },
EOF
fi

if [[ -n $(which g++) ]]
then
    cat >>launch.json <<EOF
    {
      "name": "g++ run active file (Debug)",
      "type": "cppdbg",
      "request": "launch",
      "program": "\${fileDirname}/\${fileBasenameNoExtension}",
      "stopAtEntry": false,
      "cwd": "\${fileDirname}",
      "environment": [],
      "externalConsole": false,
      "MIMode": "gdb",
      "miDebuggerPath": "$(which gdb)",
      "setupCommands": [
        {
          "description": "Enable pretty-printing for gdb",
          "text": "-enable-pretty-printing",
          "ignoreFailures": true
        }
      ],
      "preLaunchTask": "g++ build active file (Debug)"
    },
EOF
fi

if [[ -n $(which gfortran) ]]
then
    cat >>launch.json <<EOF
    {
      "name": "gfortran run active file (Debug)",
      "type": "cppdbg",
      "request": "launch",
      "program": "\${fileDirname}/\${fileBasenameNoExtension}",
      "stopAtEntry": false,
      "cwd": "\${fileDirname}",
      "environment": [],
      "externalConsole": false,
      "MIMode": "gdb",
      "miDebuggerPath": "$(which gdb)",
      "setupCommands": [
        {
          "description": "Enable pretty-printing for gdb",
          "text": "-enable-pretty-printing",
          "ignoreFailures": true
        }
      ],
      "preLaunchTask": "gfortran build active file (Debug)"
    },
EOF
fi

if [[ -n $(which gcc) ]]
then
    cat >>launch.json <<EOF
    {
      "name": "gcc run active file (Release)",
      "type": "cppdbg",
      "request": "launch",
      "program": "\${fileDirname}/\${fileBasenameNoExtension}",
      "stopAtEntry": false,
      "cwd": "\${fileDirname}",
      "environment": [],
      "externalConsole": false,
      "MIMode": "gdb",
      "miDebuggerPath": "$(which gdb)",
      "setupCommands": [
        {
          "description": "Enable pretty-printing for gdb",
          "text": "-enable-pretty-printing",
          "ignoreFailures": true
        }
      ],
      "preLaunchTask": "gcc build active file (Release)"
    },
EOF
fi

if [[ -n $(which g++) ]]
then
    cat >>launch.json <<EOF
    {
      "name": "g++ run active file (Release)",
      "type": "cppdbg",
      "request": "launch",
      "program": "\${fileDirname}/\${fileBasenameNoExtension}",
      "stopAtEntry": false,
      "cwd": "\${fileDirname}",
      "environment": [],
      "externalConsole": false,
      "MIMode": "gdb",
      "miDebuggerPath": "$(which gdb)",
      "setupCommands": [
        {
          "description": "Enable pretty-printing for gdb",
          "text": "-enable-pretty-printing",
          "ignoreFailures": true
        }
      ],
      "preLaunchTask": "g++ build active file (Release)"
    },
EOF
fi

if [[ -n $(which gfortran) ]]
then
    cat >>launch.json <<EOF
    {
      "name": "gfortran run active file (Release)",
      "type": "cppdbg",
      "request": "launch",
      "program": "\${fileDirname}/\${fileBasenameNoExtension}",
      "stopAtEntry": false,
      "cwd": "\${fileDirname}",
      "environment": [],
      "externalConsole": false,
      "MIMode": "gdb",
      "miDebuggerPath": "$(which gdb)",
      "setupCommands": [
        {
          "description": "Enable pretty-printing for gdb",
          "text": "-enable-pretty-printing",
          "ignoreFailures": true
        }
      ],
      "preLaunchTask": "gfortran build active file (Release)"
    },
EOF
fi

if [[ -n $(which icc) ]]
then
    cat >>launch.json <<EOF
    {
      "name": "icc run active file (Debug)",
      "type": "cppdbg",
      "request": "launch",
      "program": "\${fileDirname}/\${fileBasenameNoExtension}",
      "stopAtEntry": false,
      "cwd": "\${fileDirname}",
      "environment": [],
      "externalConsole": false,
      "MIMode": "gdb",
      "miDebuggerPath": "$(which gdb)",
      "setupCommands": [
        {
          "description": "Enable pretty-printing for gdb",
          "text": "-enable-pretty-printing",
          "ignoreFailures": true
        }
      ],
      "preLaunchTask": "icc build active file (Debug)"
    },
EOF
fi

if [[ -n $(which icpc) ]]
then
    cat >>launch.json <<EOF
    {
      "name": "icpc run active file (Debug)",
      "type": "cppdbg",
      "request": "launch",
      "program": "\${fileDirname}/\${fileBasenameNoExtension}",
      "stopAtEntry": false,
      "cwd": "\${fileDirname}",
      "environment": [],
      "externalConsole": false,
      "MIMode": "gdb",
      "miDebuggerPath": "$(which gdb)",
      "setupCommands": [
        {
          "description": "Enable pretty-printing for gdb",
          "text": "-enable-pretty-printing",
          "ignoreFailures": true
        }
      ],
      "preLaunchTask": "icpc build active file (Debug)"
    },
EOF
fi

if [[ -n $(which ifort) ]]
then
    cat >>launch.json <<EOF
    {
      "name": "ifort run active file (Debug)",
      "type": "cppdbg",
      "request": "launch",
      "program": "\${fileDirname}/\${fileBasenameNoExtension}",
      "stopAtEntry": false,
      "cwd": "\${fileDirname}",
      "environment": [],
      "externalConsole": false,
      "MIMode": "gdb",
      "miDebuggerPath": "$(which gdb)",
      "setupCommands": [
        {
          "description": "Enable pretty-printing for gdb",
          "text": "-enable-pretty-printing",
          "ignoreFailures": true
        }
      ],
      "preLaunchTask": "ifort build active file (Debug)"
    },
EOF
fi

if [[ -n $(which icc) ]]
then
    cat >>launch.json <<EOF
    {
      "name": "icc run active file (Release)",
      "type": "cppdbg",
      "request": "launch",
      "program": "\${fileDirname}/\${fileBasenameNoExtension}",
      "stopAtEntry": false,
      "cwd": "\${fileDirname}",
      "environment": [],
      "externalConsole": false,
      "MIMode": "gdb",
      "miDebuggerPath": "$(which gdb)",
      "setupCommands": [
        {
          "description": "Enable pretty-printing for gdb",
          "text": "-enable-pretty-printing",
          "ignoreFailures": true
        }
      ],
      "preLaunchTask": "icc build active file (Release)"
    },
EOF
fi

if [[ -n $(which icpc) ]]
then
    cat >>launch.json <<EOF
    {
      "name": "icpc run active file (Release)",
      "type": "cppdbg",
      "request": "launch",
      "program": "\${fileDirname}/\${fileBasenameNoExtension}",
      "stopAtEntry": false,
      "cwd": "\${fileDirname}",
      "environment": [],
      "externalConsole": false,
      "MIMode": "gdb",
      "miDebuggerPath": "$(which gdb)",
      "setupCommands": [
        {
          "description": "Enable pretty-printing for gdb",
          "text": "-enable-pretty-printing",
          "ignoreFailures": true
        }
      ],
      "preLaunchTask": "icpc build active file (Release)"
    },
EOF
fi

if [[ -n $(which ifort) ]]
then
    cat >>launch.json <<EOF
    {
      "name": "ifort run active file (Release)",
      "type": "cppdbg",
      "request": "launch",
      "program": "\${fileDirname}/\${fileBasenameNoExtension}",
      "stopAtEntry": false,
      "cwd": "\${fileDirname}",
      "environment": [],
      "externalConsole": false,
      "MIMode": "gdb",
      "miDebuggerPath": "$(which gdb)",
      "setupCommands": [
        {
          "description": "Enable pretty-printing for gdb",
          "text": "-enable-pretty-printing",
          "ignoreFailures": true
        }
      ],
      "preLaunchTask": "ifort build active file (Release)"
    },
EOF
fi

cat >>launch.json <<EOF
    {
      "name": "run from Makefile",
      "type": "cppdbg",
      "request": "launch",
      "program": "\${fileDirname}/npbound",
      "stopAtEntry": false,
      "cwd": "\${fileDirname}",
      "environment": [],
      "externalConsole": false,
      "MIMode": "gdb",
      "miDebuggerPath": "$(which gdb)",
      "setupCommands": [
        {
          "description": "Enable pretty-printing for gdb",
          "text": "-enable-pretty-printing",
          "ignoreFailures": true
        }
      ],
      "preLaunchTask": "make command task"
    },
EOF

cat >>launch.json <<EOF
  ]
}
EOF

echo "launch.json Configured"
mv ./launch.json ./.vscode/
mv ./tasks.json ./.vscode/

cat <<EOF


--------------------------------------------
Checking vscode extension requirements
--------------------------------------------
EOF

if [[ -n $(code --list-extensions | grep "python") ]]
then
    installPythonExt=$(code --list-extensions | grep "python" | head -1)
else
    installPythonExt="Not found"
fi

if [[ -n $(code --list-extensions | grep "cpptools") ]]
then
    installCpptoolsExt=$(code --list-extensions | grep "cpptools" | head -1)
else
    installCpptoolsExt="Not found"
fi

if [[ -n $(code --list-extensions | grep "gfortran") ]]
then
    installFortranExt=$(code --list-extensions | grep "gfortran" | head -1)
else
    installFortranExt="Not found"
fi

cat <<EOF
Python-extension:       $installPythonExt
C/C++ -extension:       $installCpptoolsExt
Fortran-extension:      $installFortranExt

Checking Complete.
The missing extension will be installed.
EOF

if [[ $installPythonExt = "Not found" ]]
then
    echo "Executing: code --install-extension ms-python.python"
    code --install-extension ms-python.python
fi

if [[ $installCpptoolsExt = "Not found" ]]
then
    echo "Executing: code --install-extension ms-vscode.cpptools"
    code --install-extension ms-vscode.cpptools
fi

if [[ $installFortranExt = "Not found" ]]
then
    echo "Executing: code --install-extension krvajalm.linter-gfortran"
    code --install-extension krvajalm.linter-gfortran
fi

code -a .
cat <<EOF

Setup completed. 
--------------------------------------------
Use "Ctrl + Shift + P" and Type "Workspaces: Save Workspace As" to save these settings into a workspace in VSCode.
Use "Ctrl + Shift + P" and Type "File: Open Workspace" to load this profile in VSCode.

--------------------------------------------
Notes: The "program" in file "run from Makefile" located at ./.vscode/launch.json should be modified. The default Filename from Makefile is 'npbound'.
EOF