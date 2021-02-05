#!/bin/csh
# Usage: ./update_FV3Bundle.csh base_directory
set basedir = $1
echo "Basedir: "$basedir
set dirlist = "( atlas fckit )"

foreach dir ${dirlist}
   echo "Updating ${dir}"
   cd ${basedir}/${dir}
   git remote update
   git checkout release-stable
   git pull
   echo
end

#ioda-converters
#soca
set dirlist = "( crtm femps fms fv3-jedi fv3-jedi-lm ioda oops saber ufo )"

foreach dir ${dirlist}
   echo "Updating ${dir}"
   cd ${basedir}/${dir}
   git remote update
   git pull
   echo
end
