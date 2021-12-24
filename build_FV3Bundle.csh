#!/bin/csh
# Usage: ./build_FV3Bundle.csh directory_path directory_name platform
set dir_path = $1
set dir_name = $2
set platform = $3
#
set fv3Bundle_git = 'https://github.com/JCSDA-internal/fv3-bundle.git'
#

echo "******************************************************************"
echo '    Command:' mkdir -p $dir_path/$dir_name/jedi_build
mkdir -p $dir_path/$dir_name/jedi_build

#Load JEDI modules: https://jointcenterforsatellitedataassimilation-jedi-docs.readthedocs-hosted.com/en/latest/using/jedi_environment/modules.html
echo "******************************************************************"
echo '    Command: Load JEDI Modules'
if ( $platform == 'hera' ) then
setenv JEDI_OPT /scratch1/NCEPDEV/jcsda/jedipara/opt/modules
module use $JEDI_OPT/modulefiles/core
module purge
module load jedi/intel-impi/2020.2
else
setenv JEDI_OPT /work/noaa/da/jedipara/opt/modules
module use $JEDI_OPT/modulefiles/core
module load jedi/intel-impi
endif
module list
echo "*-----------------------------------------------------------------"
echo '    Command:' cd $dir_path/$dir_name
echo '    Command:' git clone $fv3Bundle_git
echo '    Command:' cd $dir_path/$dir_name/fv3-bundle
if ( -d $dir_path/$dir_name/fv3-bundle ) then
    cd $dir_path/$dir_name/fv3-bundle
    git pull
else
    cd $dir_path/$dir_name
    git clone $fv3Bundle_git
    cd $dir_path/$dir_name/fv3-bundle
endif
echo "*-----------------------------------------------------------------"
echo '    Command:' cd $dir_path/$dir_name/jedi_build
echo '    Command: build the system'
cd $dir_path/$dir_name/jedi_build
if ( $platform == 'hera' ) then
ecbuild -DMPIEXEC_EXECUTABLE=`which srun` -DMPIEXEC_NUMPROC_FLAG="-n" ../fv3-bundle
else
ecbuild -DMPIEXEC_EXECUTABLE=/opt/slurm/bin/srun -DMPIEXEC_NUMPROC_FLAG="-n" ../fv3-bundle
endif
export SLURM_ACCOUNT=da-cpu
export SALLOC_ACCOUNT=$SLURM_ACCOUNT
export SBATCH_ACCOUNT=$SLURM_ACCOUNT
export SLURM_QOS=debug
echo '    Command:' make -j4
make -j4
