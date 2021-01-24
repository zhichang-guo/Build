#!/bin/csh
# Usage: ./build_LandDriver.csh directory_path directory_name
set dir_path = $1
set dir_name = $2
set fort_compiler = '/apps/intel/parallel_studio_xe_2020.2.108/compilers_and_libraries_2020/linux/bin/intel64/ifort'
#
set driver_git = 'https://github.com/barlage/ufs-land-driver.git'
set driver_branch = 'feature/noahmp'
#
#set ccpp_git = 'https://github.com/HelinWei-NOAA/ccpp-physics.git'
#set ccpp_branch = 'feature/noahmp'
#
set ccpp_git = 'https://github.com/barlage/ccpp-physics.git'
set ccpp_branch = 'bug_opt_stc'

echo "******************************************************************"
echo '    Command:' mkdir -p $dir_path/$dir_name 
mkdir -p $dir_path/$dir_name

echo "*-----------------------------------------------------------------"
echo '    Command:' cd $dir_path/$dir_name
echo '    Command:' git clone $driver_git
echo '    Command:' cd $dir_path/$dir_name/ufs-land-driver
echo '    Command:' git fetch
echo '    Command:' git checkout $driver_branch
cd $dir_path/$dir_name
git clone $driver_git
cd $dir_path/$dir_name/ufs-land-driver
git fetch
git checkout $driver_branch

echo "*-----------------------------------------------------------------"
echo '    Command:' cd $dir_path/$dir_name
echo '    Command:' git clone $ccpp_git
echo '    Command:' cd $dir_path/$dir_name/ccpp-physics
echo '    Command:' git fetch
echo '    Command:' git checkout $ccpp_branch
cd $dir_path/$dir_name
git clone $ccpp_git
cd $dir_path/$dir_name/ccpp-physics
git fetch
git checkout $ccpp_branch

echo "*-----------------------------------------------------------------"
echo '    Command:' cd $dir_path/$dir_name/ufs-land-driver
cd $dir_path/$dir_name/ufs-land-driver
echo '    Command: cat user_build_config'
cat > user_build_config << EOF
#===============================================================================
#  Placeholder options for intel fortran in hera
#===============================================================================

 COMPILERF90    =       $fort_compiler
 FREESOURCE     =       #-ffree-form  -ffree-line-length-none
 F90FLAGS       =       -r8
 NETCDFMOD      =       -I/apps/netcdf/4.7.0/intel/18.0.5.274/include
 NETCDFLIB      =       -L/apps/netcdf/4.7.0/intel/18.0.5.274/lib -lnetcdf -lnetcdff
 PHYSDIR        =       $dir_path/$dir_name/ccpp-physics/physics
EOF
cat $dir_path/$dir_name/ufs-land-driver/user_build_config

echo "*-----------------------------------------------------------------"
echo '    Command:' cd $dir_path/$dir_name/ufs-land-driver
echo '    Command:' make
cd $dir_path/$dir_name/ufs-land-driver
make
