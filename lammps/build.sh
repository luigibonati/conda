#!/bin/bash
set -e

# Since this version is compiled with MPI, it should not pass a communicator to PLUMED
cat src/USER-PLUMED/fix_plumed.cpp | grep -v setMPIComm > src/USER-PLUMED/fix_plumed.cpp.fix
mv src/USER-PLUMED/fix_plumed.cpp.fix src/USER-PLUMED/fix_plumed.cpp

# Fix the name of the PLUMED kernel on OSX
if [[ $(uname) == Darwin ]]; then
  cat lib/plumed/Makefile.lammps.runtime | sed "s/libplumedKernel.so/libplumedKernel.dylib/" > lib/plumed/Makefile.lammps.runtime.fix
  mv lib/plumed/Makefile.lammps.runtime.fix lib/plumed/Makefile.lammps.runtime
fi

cd src
make lib-plumed args="-p $PREFIX -m runtime"
make yes-kspace
make yes-molecule
make yes-rigid
make yes-manybody
make yes-user-plumed
make -j${CPU_COUNT} serial
cp lmp_serial $PREFIX/bin/lmp_serial
