#!/bin/csh
# Usage: ./build_FV3Bundle.csh directory_path directory_name platform
set dir_path = $1
set dir_name = $2
set platform = $3
#
set fv3Bundle_git = 'https://github.com/JCSDA-internal/fv3-bundle.git'
#

echo "******************************************************************"
echo '    Command:' mkdir -p $dir_path/$dir_name
echo '    Command:' mkdir -p $dir_path/$dir_name/build
mkdir -p $dir_path/$dir_name
mkdir -p $dir_path/$dir_name/build

#Load JEDI modules: https://jointcenterforsatellitedataassimilation-jedi-docs.readthedocs-hosted.com/en/latest/using/jedi_environment/modules.html
echo "******************************************************************"
echo '    Command: Load JEDI Modules'
if ($platform == 'hera') then
    setenv JEDI_OPT /scratch1/NCEPDEV/jcsda/jedipara/opt/modules
    module use $JEDI_OPT/modulefiles/core
    module purge
    module load jedi/intel-impi/2020.2
    module list
else
    export JEDI_OPT=/work/noaa/da/jedipara/opt/modules
    module use $JEDI_OPT/modulefiles/core
    module load anaconda/anaconda3-2020.04.02
    module load jedi/intel-impi
endif

echo "*-----------------------------------------------------------------"
echo '    Command:' cd $dir_path/$dir_name
echo '    Command:' git clone $fv3Bundle_git
echo '    Command:' cd $dir_path/$dir_name/fv3-bundle
cd $dir_path/$dir_name
git clone $fv3Bundle_git
cd $dir_path/$dir_name/fv3-bundle

echo "*-----------------------------------------------------------------"
echo '    Command:' cd $dir_path/$dir_name/build
cd $dir_path/$dir_name/build
if ($platform == 'hera') then
    echo '    Command:' ecbuild -DMPIEXEC_EXECUTABLE=`which srun` -DMPIEXEC_NUMPROC_FLAG="-n" ../fv3-bundle
    ecbuild -DMPIEXEC_EXECUTABLE=`which srun` -DMPIEXEC_NUMPROC_FLAG="-n" ../fv3-bundle
    echo '    Command:' export SLURM_ACCOUNT=da-cpu
    export SLURM_ACCOUNT=da-cpu
    echo '    Command:' export SALLOC_ACCOUNT=$SLURM_ACCOUNT
    export SALLOC_ACCOUNT=$SLURM_ACCOUNT
    echo '    Command:' export SBATCH_ACCOUNT=$SLURM_ACCOUNT
    export SBATCH_ACCOUNT=$SLURM_ACCOUNT
    echo '    Command:' export SLURM_QOS=debug
    export SLURM_QOS=debug
else
    echo '    Command:' ecbuild -DMPIEXEC_EXECUTABLE=/opt/slurm/bin/srun -DMPIEXEC_NUMPROC_FLAG="-n" ../fv3-bundle
    ecbuild -DMPIEXEC_EXECUTABLE=/opt/slurm/bin/srun -DMPIEXEC_NUMPROC_FLAG="-n" ../fv3-bundle
    echo '    Command:' export SLURM_ACCOUNT=da-cpu
    export SLURM_ACCOUNT=da-cpu
    echo '    Command:' export SALLOC_ACCOUNT=$SLURM_ACCOUNT
    export SALLOC_ACCOUNT=$SLURM_ACCOUNT
    echo '    Command:' export SBATCH_ACCOUNT=$SLURM_ACCOUNT
    export SBATCH_ACCOUNT=$SLURM_ACCOUNT
    echo '    Command:' export SLURM_QOS=debug
    export SLURM_QOS=debug
endif
echo '    Command:' export SLURM_ACCOUNT=da-cpu
setenv SLURM_ACCOUNT da-cpu
echo '    Command:' export SALLOC_ACCOUNT=$SLURM_ACCOUNT
setenv SALLOC_ACCOUNT $SLURM_ACCOUNT
echo '    Command:' export SBATCH_ACCOUNT=$SLURM_ACCOUNT
setenv SBATCH_ACCOUNT $SLURM_ACCOUNT
echo '    Command:' export SLURM_QOS=debug
setenv SLURM_QOS debug
echo '    Command:' make -j4
make -j4
