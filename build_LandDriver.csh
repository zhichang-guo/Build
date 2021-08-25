#!/bin/csh
# Usage: ./build_LandDriver.csh directory_path directory_name platform
set dir_path = $1
set dir_name = $2
set platform = $3
set rootdir  = $PWD
set dir      = $rootdir/$dir_path/$dir_name
if ($platform == 'hera') then
    #source /home/Zhichang.Guo/rcs/Load_jedi_modules.rc
    /home/Zhichang.Guo/rcs/modulefile.soca.hera.bsh
    set fort_compiler = 'apps/intel/parallel_studio_xe_2020.2.108/compilers_and_libraries_2020/linux/bin/intel64/ifort'
    set netcdf_dir    = 'apps/netcdf/4.7.4/intel/18.0.5'
    set fflags        = '-r8'
else
    set fort_compiler = 'apps/gcc-10.2.0/openmpi-4.0.4/openmpi-4.0.4/bin/mpifort'
    set netcdf_dir    = 'work/noaa/da/grubin/opt/modules/gnu-10.2.0/openmpi-4.0.4/netcdf/4.7.4'
    set fflags        = '-O2 -funroll-all-loops -finline-functions'
endif

#******************** EMC UFS Land Driver ********************
set driver_git = 'https://github.com/barlage/ufs-land-driver.git'
set driver_branch = ''
#set driver_branch = 'new_noahmp'
#set driver_branch = 'feature/noahmp'
#
#set ccpp_git = 'https://github.com/HelinWei-NOAA/ccpp-physics.git'
#set ccpp_branch = 'feature/noahmp'
#
set ccpp_git = 'https://github.com/barlage/ccpp-physics.git'
set ccpp_branch = 'update_noahmp'
#set ccpp_branch = 'bug_opt_stc'
#
echo "******************************************************************"
if ( -d ${dir} ) then
    echo '    The directory exists:' $dir
else
    echo '    Command:' mkdir -p $dir
    mkdir -p $dir
endif
#
echo "*-----------------------------------------------------------------"
echo '    Command 00:' cd $dir
echo '    Command 01:' git clone $driver_git
echo '    Command 02:' cd $dir/ufs-land-driver
cd $dir
git clone $driver_git
if ($driver_branch != '') then
  echo '    Command 03:' git fetch
  echo '    Command 04:' git checkout $driver_branch
  cd $dir/ufs-land-driver
  git fetch
  git checkout $driver_branch
endif

#******************** EMC UFS Land CCPP Physics ********************
echo "*-----------------------------------------------------------------"
echo '    Command 05:' cd $dir
echo '    Command 06:' git clone $ccpp_git
echo '    Command 07:' cd $dir/ccpp-physics
echo '    Command 08:' git fetch
echo '    Command 09:' git checkout $ccpp_branch
cd $dir
git clone $ccpp_git
cd $dir/ccpp-physics
git fetch
git checkout $ccpp_branch
#
echo "*-----------------------------------------------------------------"
echo '    Command:' cd $dir/ufs-land-driver
cd $dir/ufs-land-driver

#******************** Build EMC UFS Land Driver and Models ********************
echo '    Command: cat user_build_config'
cat > user_build_config << EOF
#===============================================================================
#  Placeholder options for intel fortran in hera
#===============================================================================
 COMPILERF90    =       /$fort_compiler
 FREESOURCE     =       #-ffree-form  -ffree-line-length-none
 F90FLAGS       =       $fflags
 NETCDFMOD      =       -I/$netcdf_dir/include
 NETCDFLIB      =       -L/$netcdf_dir/lib -lnetcdf -lnetcdff
 PHYSDIR        =       $dir/ccpp-physics/physics
EOF
cat $dir/ufs-land-driver/user_build_config
#
echo "*-----------------------------------------------------------------"
echo '    Command:' cd $dir/ufs-land-driver
echo '    Command:' make
cd $dir/ufs-land-driver
sed -i -- 's/sfc_noahmp_drv/noahmp_sfc_drv/g' $dir/ufs-land-driver/*/Makefile
make
set exefile = $dir/ufs-land-driver/run/ufsLand.exe
if ( -f $exefile ) then
    echo '    The executable file is created successfully!' 
else
    echo '    The executable file is not created!' 
endif
