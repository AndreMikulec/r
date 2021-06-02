
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
    #
    # all cases - better
    sed -i -e "s/-gdwarf-2/--enable-cassert -ggdb -Og -g3 -fno-omit-frame-pointer/" ${rsource}/src/gnuwin32/fixed/etc/Makeconf
    loginfo                                                                    "cat ${rsource}/src/gnuwin32/fixed/etc/Makeconf"
                                                                                cat ${rsource}/src/gnuwin32/fixed/etc/Makeconf
    
    # better debugging
    cp ${rsource}/src/gnuwin32/MkRules.dist                                         ${rsource}/src/gnuwin32/MkRules.local
    echo "G_FLAG = --enable-cassert -ggdb -Og -g3 -fno-omit-frame-pointer"       >> ${rsource}/src/gnuwin32/MkRules.local
    loginfo                                                                    "cat ${rsource}/src/gnuwin32/MkRules.local"
                                                                                cat ${rsource}/src/gnuwin32/MkRules.local
    #
    # if I want to use openblas
    sed -i "s/-lf77blas -latlas\b/-lopenblas/" ${rsource}/configure
    loginfo                               cat "${rsource}/configure"
                                          cat  ${rsource}/configure
    #
    sed -i "s/-lf77blas -latlas\b/-lopenblas/" ${rsource}/src/extra/blas/Makefile.win
    loginfo                              "cat ${rsource}/src/extra/blas/Makefile.win"
                                          cat ${rsource}/src/extra/blas/Makefile.win
    #
    # UNVERIFIED # I WILL FIX THIS LATER
    echo "QPDF = /usr/lib/" >> ${rsource}/src/gnuwin32/MkRules.local
    loginfo               "cat ${rsource}/src/gnuwin32/MkRules.local"
                           cat ${rsource}/src/gnuwin32/MkRules.local
    #
    # https://stackoverflow.com/questions/51364034/how-can-i-install-r-in-linux-server-when-i-run-the-configure-command-i-am-get
    # 
    # Compiling from source
    # --enable-R-shlib
    # https://github.com/postgres-plr/plr/blob/master/userguide.md
    #
    # EXPLICIT ADDITIONAL FLAGS
    # https://stackoverflow.com/questions/62226472/why-doesnt-my-gcc-compiler-recognize-the-bzip2-functions-yet-allows-me-to-incl
    #
    # https://unix.stackexchange.com/questions/149359/what-is-the-correct-syntax-to-add-cflags-and-ldflags-to-configure/149361
    #
    # https://github.com/AndreMikulec/plr/blob/1d57ca52b03dde8f7d32d9bb96c1ea45f011e4af/build_script.sh#L40
    #
    cd ${rsource}
    #
    # see configure options
    ./configure --help
    #
    #
    # without: "LDFLAGS=-L /usr/lib -l bz2" (do not do this)
    # checking for BZ2_bzlibVersion in -lbz2... no
    # checking whether bzip2 support suffices... configure: error: bzip2 library and headers are required
    #
    # with: "LDFLAGS=-L /usr/lib -l bz2" (do not do this)
    # configure: error: C compiler cannot create executables
    #
    # 
    # Must choose one or the other
    # --without-pcre2 --without-pcre1
    #
    # checking whether PCRE support suffices... no
    # configure: error: PCRE2 library and headers are required, or use --with-pcre1 and PCRE >= 8.32 with UTF-8 support
    #
    # defaults:
    # --with-pcre2
    #
    # see them all
    loginfo "export"
    export
    # make sure all my (new) files are where they should be
    loginfo "find ${rsource} -type f -print"
    find ${rsource} -type f -print
    #
    if [ "${Configuration}" == "Release" ]
    then
      # ./configure "LDFLAGS=-L /usr/lib -l bz2" --disable-rpath --enable-java=no --enable-R-shlib --prefix=${rroot} 2>&1 | tee config_interactive.log
      # without (almost) everything and doing (--disable-rpath)
      # ./configure --enable-R-profiling=no --enable-BLAS-shlib=no --enable-java=no --enable-byte-compiled-packages=no --enable-shared=no --enable-fast-install=no --enable-long-double=no --disable-rpath --without-readline --without-tcltk --without-cairo --without-libpng --without-jpeglib --without-libtiff --without-internal-wcwidth --without-recommended-packages --without-ICU --without-sysroot --without-x --without-libpth-prefix --without-libintl-prefix --prefix=${rroot} 2>&1 | tee config_interactive.log 
    fi
    if [ "${Configuration}" == "Debug" ] 
    then
    ##
    ## NO DIFFERENT THAN "Release": later "make DEBUG=T"
    ## https://cran.r-project.org/bin/windows/base/rw-FAQ.html#How-do-I-debug-code-that-I-have-compiled-and-dyn_002eload_002ded_003f
    ##
      # ./configure "LDFLAGS=-L /usr/lib -l bz2" --disable-rpath --enable-java=no --enable-R-shlib --prefix=${rroot} 2>&1 | tee config_interactive.log
      # without (almost) everything and doing (--disable-rpath)
      # ./configure --enable-R-profiling=no --enable-BLAS-shlib=no --enable-java=no --enable-byte-compiled-packages=no --enable-shared=no --enable-fast-install=no --enable-long-double=no  --without-readline --without-tcltk --without-cairo --without-libpng --without-jpeglib --without-libtiff --without-internal-wcwidth --without-recommended-packages --without-ICU --without-sysroot --without-x --without-libpth-prefix --without-libintl-prefix --prefix=${rroot} 2>&1 | tee config_interactive.log
      #
      # R is now configured for x86_64-pc-cygwin
      #   Source directory:            .
      #   Installation directory:      /cygdrive/c/RINSTALL
      #   C compiler:                  gcc  -g -O2
      #   Fortran fixed-form compiler: gfortran -fno-optimize-sibling-calls -g -O2
      #   Default C++ compiler:        g++ -std=gnu++14  -g -O2
      #   C++11 compiler:              g++ -std=gnu++11  -g -O2
      #   C++14 compiler:              g++ -std=gnu++14  -g -O2
      #   C++17 compiler:              g++ -std=gnu++17  -g -O2
      #   C++20 compiler:              g++ -std=gnu++20  -g -O2
      #   Fortran free-form compiler:  gfortran -fno-optimize-sibling-calls -g -O2
      #   Obj-C compiler:	        
      #   Interfaces supported:        
      #   External libraries:          pcre2, curl
      #   Additional capabilities:     NLS
      #   Options enabled:             
      #   Capabilities skipped:        PNG, JPEG, TIFF, cairo, ICU
      #   Options not enabled:         shared BLAS, R profiling, memory profiling
      #   Recommended packages:        no
      # configure: WARNING: you cannot build PDF versions of the R manuals
      # configure: WARNING: you cannot build PDF versions of vignettes and help pages
      # configure: WARNING: I could not determine a browser
      # configure: WARNING: I could not determine a PDF viewer
      #
      #
      # undefined references everywhere - try compiling with near-default
      #
      ./configure --disable-rpath --enable-R-shlib --prefix=${rroot} 2>&1 | tee config_interactive.log
      
    fi
    loginfo "END   R CONFIGURE"
    loginfo "BEGIN R BUILD"
    if [ "${Configuration}" == "Release" ]
    then
      make USE_ATLAS=YES ATLAS_PATH=/use/lib/
    fi
    if [ "${Configuration}" == "Debug" ]
    then
      # https://cran.r-project.org/bin/windows/base/rw-FAQ.html#How-do-I-debug-code-that-I-have-compiled-and-dyn_002eload_002ded_003f
      make USE_ATLAS=YES ATLAS_PATH=/use/lib/ DEBUG=T 
      # failing to pickup my debugging and flags
      #
    fi
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
