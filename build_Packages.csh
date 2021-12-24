#!/bin/csh
############################################################
## Build/update a JEDI related system                      #
##                                                         #
## Usage: ./build_Packages.csh package directory platform  #
##        packages: fv3-bundle/soca/ucldasv2/ioda-bundle   #
##        platform: hera or orion                          #
## Example:                                                #
##        ./build_Packages.csh fv3-bundle Work orion       #
##        The script will build fv3-build under the        #
##        directory "Work" on hera                         #
## Author: Zhichang Guo, email: Zhichang.Guo@noaa.gov      #
############################################################
if ( $#argv != 3) then
  echo $0 requires 3 arguments: package directory platform
  echo '        packages: fv3-bundle/soca/ucldasv2/ioda-bundle' 
  echo '        platform: hera or orion'
  exit
else
  echo $0 $1 $2 $3
endif

set package   = $1
set directory = $2
set platform  = $3
set status    = 'init'
#
if ( $package == 'fv3-bundle' ) then
    set package_git = 'https://github.com/JCSDA-internal/fv3-bundle.git'
    set dir_build = 'jedi_build'
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
endif
#

echo "******************************************************************"
echo '    Command:' mkdir -p $directory/$dir_build
mkdir -p $directory/$dir_build

#Load JEDI modules: https://jointcenterforsatellitedataassimilation-jedi-docs.readthedocs-hosted.com/en/latest/using/jedi_environment/modules.html
echo "******************************************************************"
echo '    Command: Load Package Modules'
if ( $package == 'fv3-bundle' || $package == 'soca' || $package == 'ucldasv2' ) then
    if ( $platform == 'hera' ) then
        setenv JEDI_OPT /scratch1/NCEPDEV/jcsda/jedipara/opt/modules
        module use $JEDI_OPT/modulefiles/core
        module purge
        module load jedi/intel-impi/2020.2
    else if ( $platform == 'orion' ) then
        setenv JEDI_OPT /work/noaa/da/jedipara/opt/modules
        module use $JEDI_OPT/modulefiles/core
        module load jedi/intel-impi
    endif
endif
module list
echo "*-----------------------------------------------------------------"
echo '    Command:' cd $directory
echo '    Command:' git clone $package_git
echo '    Command:' cd $directory/$dir_src
if ( -d $directory/$dir_src ) then
    cd $directory/$dir_src
    git pull
    set status = 'updated'
else
    cd $directory
    git clone $package_git
endif
echo "*-----------------------------------------------------------------"
echo '    Command:' cd $directory/$dir_build
echo '    Command: build the system'
cd $directory/$dir_build
if ( $package == 'fv3-bundle' || $package == 'soca' || $package == 'ucldasv2' ) then
    if ( $status == 'init' ) then
        if ( $platform == 'hera' ) then
            ecbuild -DMPIEXEC_EXECUTABLE=`which srun` -DMPIEXEC_NUMPROC_FLAG="-n" ../$dir_start
        else
            ecbuild -DMPIEXEC_EXECUTABLE=/opt/slurm/bin/srun -DMPIEXEC_NUMPROC_FLAG="-n" ../$dir_start
        endif
    endif
endif
setenv SLURM_ACCOUNT da-cpu
setenv SALLOC_ACCOUNT $SLURM_ACCOUNT
setenv SBATCH_ACCOUNT $SLURM_ACCOUNT
setenv SLURM_QOS debug
echo '    Command:' make -j4
cd $directory/$dir_build
make -j4
