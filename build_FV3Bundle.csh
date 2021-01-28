#!/bin/csh
# Usage: ./build_FV3Bundle.csh directory_path directory_name
set dir_path = $1
set dir_name = $2
#
set fv3Bundle_git = 'https://github.com/JCSDA/fv3-bundle.git'
#

echo "******************************************************************"
echo '    Command:' mkdir -p $dir_path/$dir_name/src
echo '    Command:' mkdir -p $dir_path/$dir_name/build
mkdir -p $dir_path/$dir_name/src
mkdir -p $dir_path/$dir_name/build

echo "******************************************************************"
echo '    Command:' cat ~/rcs/Load_jedi_modules.rc
module use /scratch1/NCEPDEV/jcsda/Ryan.Honeyager/jedi-stack/opt/modulefiles/apps
module use /scratch1/NCEPDEV/jcsda/Ryan.Honeyager/jedi-stack/opt/modulefiles/core
setenv JEDI_OPT /scratch1/NCEPDEV/jcsda/Ryan.Honeyager/jedi-stack/opt
module purge
module load jedi/intel-20.2-impi-18
module list

echo "*-----------------------------------------------------------------"
echo '    Command:' cd $dir_path/$dir_name/src
echo '    Command:' git clone $fv3Bundle_git
echo '    Command:' cd $dir_path/$dir_name/src/fv3-bundle
cd $dir_path/$dir_name/src
git clone $fv3Bundle_git
cd $dir_path/$dir_name/src/fv3-bundle

echo "*-----------------------------------------------------------------"
echo '    Command:' cd $dir_path/$dir_name/build
cd $dir_path/$dir_name/build
echo '    Command:' ecbuild -DMPIEXEC_EXECUTABLE=`which srun` -DMPIEXEC_NUMPROC_FLAG="-n" ../src/fv3-bundle
ecbuild -DMPIEXEC_EXECUTABLE=`which srun` -DMPIEXEC_NUMPROC_FLAG="-n" ../src/fv3-bundle
echo '    Command:' export SLURM_ACCOUNT=da-cpu
setenv SLURM_ACCOUNT da-cpu
echo '    Command:' export SALLOC_ACCOUNT=$SLURM_ACCOUNT
setenv SALLOC_ACCOUNT $SLURM_ACCOUNT
echo '    Command:' export SBATCH_ACCOUNT=$SLURM_ACCOUNT
setenv SBATCH_ACCOUNT $SLURM_ACCOUNT
echo '    Command:' export SLURM_QOS=debug
setenv SLURM_QOS debug
echo '    Command:' make -j8
make -j8
