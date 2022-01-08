#!/bin/csh
############################################################
## Build/update a JEDI related system                      #
##                                                         #
## Usage: ./build_Packages.csh directory platform package  #
##        packages: fv3-bundle/soca/ucldasv2/ioda-bundle   #
##                  cftime/netcdf4-python/cycleDA          #
##        platform: hera or orion                          #
## Example:                                                #
##        ./build_Packages.csh ./Work orion fv3-bundle     #
##        The script will build fv3-bundle under the       #
##        directory "Work" on hera                         #
## Author: Zhichang Guo, email: Zhichang.Guo@noaa.gov      #
############################################################
if ( $#argv != 3) then
  echo $0 'requires 3 arguments: directory platform package'
  echo '        packages: fv3-bundle/soca/ucldasv2/ioda-bundle' 
  echo '                  cftime/netcdf4-python/cycleDA'
  echo '        platform: hera or orion'
  exit
else
  echo $0 $1 $2 $3
endif

set directory = $1
set platform  = $2
set package   = $3
set progress  = 'init'

echo "******************************************************************"
echo 'Step 1: setup'
if ( $package == 'fv3-bundle' ) then
    set package_git = 'https://github.com/JCSDA-internal/fv3-bundle.git'
    set dir_build = 'fv3_build'
    set dir_src   = 'fv3-bundle'
    set dir_start = 'fv3-bundle'
else if ( $package == 'soca' ) then
    set package_git = 'https://github.com/JCSDA-internal/soca.git'
    set dir_build = 'soca_build'
    set dir_src = 'soca'
    set dir_start = 'soca/bundle'
else if ( $package == 'ucldasv2' ) then
    set package_git = 'https://github.com/JCSDA-internal/ucldasv2.git'
    set dir_build = 'ucldasv2_build'
    set dir_src = 'ucldasv2'
    set dir_start = 'ucldasv2/bundle'
else if ( $package == 'ioda-bundle' ) then
    set package_git = 'https://github.com/jcsda-internal/ioda-bundle.git'
    set dir_build = 'ioda_build'
    set dir_src = 'ioda-bundle'
    set dir_start = 'ioda-bundle'
else if ( $package == 'cftime' ) then
    set package_git = 'https://github.com/Unidata/cftime.git'
    set dir_src   = 'cftime'
    set dir_build = 'cftime'
else if ( $package == 'netcdf4-python' ) then
    set package_git = 'https://github.com/Unidata/netcdf4-python'
    set dir_src   = 'netcdf4-python'
    set dir_build = 'netcdf4-python'
else if ( $package == 'cycleDA' ) then
    set package_git = 'https://github.com/ClaraDraper-NOAA/cycleDA.git'
    set dir_src   = 'cycleDA'
    set dir_build = 'cycleDA'
endif
echo '    Command: mkdir -p '$directory/$dir_build
if ( $dir_build != $dir_src ) then
    mkdir -p $directory/$dir_build
endif

echo "******************************************************************"
echo 'Step 2: load modules'
echo '    Command: Load Package Modules'
module purge
if ( $package == 'fv3-bundle' || $package == 'ioda-bundle' || $package == 'soca' || $package == 'ucldasv2' ) then
    if ( $platform == 'hera' ) then
        setenv JEDI_OPT /scratch1/NCEPDEV/jcsda/jedipara/opt/modules
        module use $JEDI_OPT/modulefiles/core
        module load jedi/intel-impi/2020.2
        if ( $package == 'ioda-bundle' ) then
            module load intelpython/3.6.8
        endif
    else if ( $platform == 'orion' ) then
        setenv JEDI_OPT /work/noaa/da/jedipara/opt/modules
        module use $JEDI_OPT/modulefiles/core
        module load jedi/intel-impi
    endif
else if ( $package == 'cftime' ) then
    if ( $platform == 'hera' ) then
        setenv JEDI_OPT /scratch1/NCEPDEV/jcsda/jedipara/opt/modules
        module use $JEDI_OPT/modulefiles/core
        module load jedi/intel-impi/2020.2
        module use -a /scratch2/NCEPDEV/marineda/Jong.Kim/save/modulefiles/
        module load anaconda/3.15.1
    else if ( $platform == 'orion' ) then
    endif
else if ( $package == 'netcdf4-python' ) then
    if ( $platform == 'hera' ) then
        module load jedi/intel-impi/2020.2
        module use -a /scratch2/NCEPDEV/marineda/Jong.Kim/save/modulefiles/
        module load anaconda/3.15.1
    else if ( $platform == 'orion' ) then
    endif
else if ( $package == 'cycleDA' ) then
    if ( $platform == 'hera' ) then
        module load intel netcdf/4.7.0
    else if ( $platform == 'orion' ) then
    endif
endif
module list

echo "*-----------------------------------------------------------------"
echo 'Step 3: git clone packages'
echo '    Command: cd '$directory
echo '    Command: git clone '$package_git
echo '    Command: cd '$directory/$dir_src
if ( -d $directory/$dir_src ) then
    echo 'cd '$directory/$dir_src
    cd $directory/$dir_src
    git pull
    set progress = 'updated'
else
    echo 'cd '$directory $package
    cd $directory
    if ( $package == 'ucldasv2' ) then
        git clone -b develop $package_git
        rm -rf $directory/$dir_src/bundle/fms $directory/$dir_src/bundle/ioda-data
        rm -rf $directory/$dir_src/bundle/jedicmake $directory/$dir_src/bundle/saber-data
        rm -rf $directory/$dir_src/bundle/ufo-data
    else if ( $package == 'cycleDA' ) then
        git clone -b jedi $package_git
        cd $directory/cycleDA
        git submodule update --init
        cd $directory/cycleDA/landDA_workflow
        git submodule update --init
        exit
    else
        echo 'git clone '$package_git
        git clone $package_git
    endif
endif

echo "*-----------------------------------------------------------------"
echo 'Step 4: build the system'
echo '    Command:' cd $directory/$dir_build
echo '    Command: build the system'
cd $directory/$dir_build
if ( $package == 'fv3-bundle' || $package == 'soca' || $package == 'ucldasv2' || $package == 'ioda-bundle' ) then
    if ( $package == 'fv3-bundle' || $package == 'soca' || $package == 'ucldasv2' ) then
        if ( $progress == 'init' ) then
            if ( $platform == 'hera' ) then
                ecbuild -DMPIEXEC_EXECUTABLE=`which srun` -DMPIEXEC_NUMPROC_FLAG="-n" ../$dir_start
            else if ( $platform == 'orion' ) then
                ecbuild -DMPIEXEC_EXECUTABLE=/opt/slurm/bin/srun -DMPIEXEC_NUMPROC_FLAG="-n" ../$dir_start
            endif
        endif
    else if ( $package == 'ioda-bundle' ) then
        if ( $progress == 'init' ) then
            if ( $platform == 'hera' ) then
                ecbuild -DMPIEXEC_EXECUTABLE=`which srun` -DMPIEXEC_NUMPROC_FLAG="-n" -DBUILD_IODA_CONVERTERS=ON -DBUILD_PYTHON_BINDINGS=ON ../$dir_start
            else if ( $platform == 'orion' ) then
                ecbuild -DMPIEXEC_EXECUTABLE=/opt/slurm/bin/srun -DMPIEXEC_NUMPROC_FLAG="-n" -DBUILD_IODA_CONVERTERS=ON -DBUILD_PYTHON_BINDINGS=ON ../$dir_start
            endif
        endif
    endif
    echo '    Command:' make -j4
    cd $directory/$dir_build
    make -j4
    setenv SLURM_ACCOUNT da-cpu
    setenv SALLOC_ACCOUNT $SLURM_ACCOUNT
    setenv SBATCH_ACCOUNT $SLURM_ACCOUNT
    setenv SLURM_QOS debug
else if ( $package == 'cftime' || $package == 'netcdf4-python' ) then
    /apps/intel/intelpython3/bin/python setup.py build
    /apps/intel/intelpython3/bin/python setup.py install --user
else if ( $package == 'cycleDA' ) then
    cd $directory/cycleDA/vector2tile
    make
    cd $directory/cycleDA/landDA_workflow/AddJediIncr
    ./build.sh
    cd $directory/cycleDA/landDA_workflow/IMSobsproc
    ./build.sh
endif
