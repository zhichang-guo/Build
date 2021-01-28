#!/bin/csh
# Usage: ./build_IODABundle.csh directory_path directory_name
set dir_path = $1
set dir_name = $2
#
#set git = 'https://github.com/JCSDA-internal/ioda-converters'
set src_dir = '/scratch1/NCEPDEV/da/Cory.R.Martin/JEDI/tutorial_dec2020/src/ioda-bundle'
#

echo "******************************************************************"
echo '    Command:' mkdir -p $dir_path/$dir_name/src
echo '    Command:' mkdir -p $dir_path/$dir_name/build
mkdir -p $dir_path/$dir_name/src
mkdir -p $dir_path/$dir_name/build

#echo "*-----------------------------------------------------------------"
#echo '    Command:' cd $dir_path/$dir_name/src
#echo '    Command:' git clone $git
#cd $dir_path/$dir_name/src
#git clone $driver_git

echo "*-----------------------------------------------------------------"
echo '    Command:' cp -r $src_dir $dir_path/$dir_name/src
cp -r $src_dir $dir_path/$dir_name/src/

echo "*-----------------------------------------------------------------"
echo '    Command:' source ~/rcs/Load_jedi_modules.rc
echo '    Command:' source ~/rcs/Load_ioda_modules.rc
echo '    Command:' cd $dir_path/$dir_name/build
echo '    Command:' ecbuild ../src/ioda-bundle
module use /scratch1/NCEPDEV/jcsda/Ryan.Honeyager/jedi-stack/opt/modulefiles/apps
module use /scratch1/NCEPDEV/jcsda/Ryan.Honeyager/jedi-stack/opt/modulefiles/core
setenv JEDI_OPT /scratch1/NCEPDEV/jcsda/Ryan.Honeyager/jedi-stack/opt
module purge
module load jedi/intel-20.2-impi-18
module list
module purge
module load jedi/intel-18-impi-18
module unload json-schema-validator/2.1.0
module unload json/3.9.1
module unload bufrlib
module load nceplibs-bufr

#source ~/rcs/Load_jedi_modules.rc
#source ~/rcs/Load_ioda_modules.rc

cd $dir_path/$dir_name/build
ecbuild ../src/ioda-bundle
cd $dir_path/$dir_name/build
make -j8
