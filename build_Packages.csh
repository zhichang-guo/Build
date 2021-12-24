#!/bin/csh
# Usage: ./build_Packages.csh package directory_path directory_name platform
if ( $#argv != 4) then
  echo $0 requires 4 arguments: package dir_path dir_name platform
  echo '        packages: fv3-bundle/soca/ucldasv2/ioda-bundle' 
  echo '        platform: hera or orion'
  exit
else
  echo $0 $1 $2 $3 $4
endif

set package  = $1
set dir_path = $2
set dir_name = $3
set platform = $4
set status   = 'init'
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
echo '    Command:' mkdir -p $dir_path/$dir_name/$dir_build
mkdir -p $dir_path/$dir_name/$dir_build

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
echo '    Command:' cd $dir_path/$dir_name
echo '    Command:' git clone $package_git
echo '    Command:' cd $dir_path/$dir_name/$dir_src
if ( -d $dir_path/$dir_name/$dir_src ) then
    cd $dir_path/$dir_name/$dir_src
    git pull
    set status = 'updated'
else
    cd $dir_path/$dir_name
    git clone $package_git
endif
echo "*-----------------------------------------------------------------"
echo '    Command:' cd $dir_path/$dir_name/$dir_build
echo '    Command: build the system'
cd $dir_path/$dir_name/$dir_build
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
cd $dir_path/$dir_name/$dir_build
make -j4
