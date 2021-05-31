
cd "$(dirname "$0")"

. ./init.sh

logok "BEGIN build_script.sh"

# set -v -x -e
set -e


#
# BEGIN (some) would have been in after_build.sh, but I need ${rversion} now
#

# also used in compiler - msvc
#
./r_version_num.sh
export r_version_num=$(cat ${APPVEYOR_BUILD_FOLDER}/r_version_num.txt)
loginfo "r_version_num ${r_version_num}"
#
# also works
# export A_VAR=$(echo -n $(sed -r 's/\s+//g' a_version_num.txt))

loginfo "r_version_num ${r_version_num}"
loginfo "OLD rversion ${rversion}"
loginfo "OLD r ${r}"

#
# override - msys2 and cygwin binary case
if [ "${r}" == "none" ]
  then
  if ([ "${rversion}" == "" ] || [ "${rversion}" == "none" ])
  then
    # later(now) - dynamically determing the R version
    export rversion=$(Rscript --vanilla -e 'cat(paste0(R.version$major,'\''.'\'',R.version$minor,tolower(R.version$status)))' 2>/dev/null)
  fi
  loginfo "NEW r ${r}"
  loginfo "NEW rversion ${rversion}"
else
  export rversion=${r_version_num}
fi
loginfo "OLD or NEW rversion ${rversion}"

#
# END   (some) would have been in after_build.sh, but I need ${rversion} now
#

# which R msys2 and cygwin
# /c/RINSTALL/bin/x64/R
# /usr/bin/R

if [ "${r}" == "none" ]
then
  loginfo "which R $(which R)"
fi


if [ "${rgithubbincacheextracted}" == "false" ] && [ ! "${r}" == "none" ]
then
  loginfo "BEGIN R EXTRACT XOR CONFIGURE+BUILD+INSTALL"
  if [ ! -f "r-r${rversion}-${Platform}-${Configuration}-${compiler}.7z" ]
  then
    loginfo "BEGIN R CONFIGURE"
    cd ${rsource}
    if [ "${Configuration}" == "Release" ]
    then
      ./configure                                                                 --prefix=${rroot}
    fi
    if [ "${Configuration}" == "Debug" ]
    then
      ./configure --enable-cassert CFLAGS="-ggdb -Og -g3 -fno-omit-frame-pointer" --prefix=${rroot}
    fi
    loginfo "END   R CONFIGURE"
    loginfo "BEGIN R BUILD"
    make -j 1 -O
    loginfo "END   R BUILD"
    loginfo "BEGIN R INSTALL"
    make install
    loginfo "END   R INSTALL"
    cd ${APPVEYOR_BUILD_FOLDER}
    loginfo "END   R BUILD + INSTALL"
  else
    loginfo "BEGIN 7z EXTRACTION"
    cd ${rroot}
    7z l "${APPVEYOR_BUILD_FOLDER}/r-r${rversion}-${Platform}-${Configuration}-${compiler}.7z"
    7z x "${APPVEYOR_BUILD_FOLDER}/r-r${rversion}-${Platform}-${Configuration}-${compiler}.7z"
    ls -alrt ${rroot}
    cd ${APPVEYOR_BUILD_FOLDER}
    loginfo "END   7z EXTRACTION"
  fi
  loginfo "END   R EXTRACT XOR CONFIGURE+BUILD+INSTALL"
fi


# put this in all non-init.sh scripts - rroot is empty, if using an msys2 binary
# but R is already in the path
if [ -f "${rroot}/lib${rbit}/R/bin/R" ]
then
  export PATH=${rroot}/lib${rbit}/R/bin:${PATH}
fi
#
# cygwin # rroot: /usr - is the general location of binaries (R) and already in the PATH
#
# $ echo $(cygpath "C:\cygwin\bin")
# /usr/bin
#

# # loginfo "BEGIN MY ENV VARIABLES"
# export
# # loginfo "END MY ENV VARIABLES"
# 
loginfo "BEGIN verify R "
loginfo "which R : $(which R)"
loginfo "END   verify R"
# 
# ls -alrt /usr/sbin
# ls -alrt ${rroot}/sbin
# which R

#
# not yet tried/tested in cygwin
#                                                                                                                           # cygwin case
if [ "${githubcache}" == "true" ] && [ "${rgithubbincachefound}" == "false" ] && ([ --f "${rroot}/lib${rbit}/R/bin/R"  ] || [ -f "${rroot}/lib${rbit}/R/bin/R" ])
then
  loginfo "BEGIN r 7z CREATION"
  cd ${rroot}
  ls -alrt
  loginfo                                            "r-r${rversion}-${Platform}-${Configuration}-${compiler}.7z"
  7z a -t7z -mmt24 -mx7 -r   ${APPVEYOR_BUILD_FOLDER}/r-r${rversion}-${Platform}-${Configuration}-${compiler}.7z *
  7z l                       ${APPVEYOR_BUILD_FOLDER}/r-r${rversion}-${Platform}-${Configuration}-${compiler}.7z
  ls -alrt                   ${APPVEYOR_BUILD_FOLDER}/r-r${rversion}-${Platform}-${Configuration}-${compiler}.7z
  export  r_7z_size=$(find  "${APPVEYOR_BUILD_FOLDER}/r-r${rversion}-${Platform}-${Configuration}-${compiler}.7z" -printf "%s")
  loginfo "r_7z_size $r_7z_size" 
  #                     96m
  if [ ${r_7z_size} -gt 100663296 ] 
  then
    rm -f    ${APPVEYOR_BUILD_FOLDER}/r-r${rversion}-${Platform}-${Configuration}-${compiler}.7z
    loginfo "${APPVEYOR_BUILD_FOLDER}/r-r${rversion}-${Platform}-${Configuration}-${compiler}.7z is TOO BIG so removed."
  fi
  #
  if [ -f "${APPVEYOR_BUILD_FOLDER}/r-r${rversion}-${Platform}-${Configuration}-${compiler}.7z" ]
  then
    if [ "${compiler}" == "cygwin" ]
    then
      # workaround of an Appveyor-using-cygwin bug - command will automatically pre-prepend A DIRECTORY (strange!)
      # e.g.
      pushd ${APPVEYOR_BUILD_FOLDER}
      #
      # NOTE FTP Deploy will automatically PushArtifact, so I will not do that HERE.
      #
      # loginfo "appveyor PushArtifact                          r-r${rversion}-${Platform}-${Configuration}-${compiler}.7z"
      #          appveyor PushArtifact                          r-r${rversion}-${Platform}-${Configuration}-${compiler}.7z
      popd
  # bash if-then-else-fi # inside bodies can not be empty
  # else
      #
      # NOTE FTP Deploy will automatically PushArtifact, so I will not do that HERE.
      #
      # loginfo "appveyor PushArtifact ${APPVEYOR_BUILD_FOLDER}/r-r${rversion}-${Platform}-${Configuration}-${compiler}.7z"
      #          appveyor PushArtifact ${APPVEYOR_BUILD_FOLDER}/r-r${rversion}-${Platform}-${Configuration}-${compiler}.7z
    fi
  fi
  #
  cd ${APPVEYOR_BUILD_FOLDER} 
  loginfo "END   r 7z CREATION"
fi

# set +v +x +e
set +e

logok "END   build_script.sh"
