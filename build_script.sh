
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

#
# Package: R
# https://cygwin.com/packages/summary/R.html
#
# maintainer(s): Marco Atzeri (Use the mailing list to report bugs or ask questions
#
# Marco Atzeri via Cygwin-announce cygwin-announce@cygwin.com
# Fri May 28 13:22:34 GMT 2021
# https://cygwin.com/pipermail/cygwin/2021-May/248616.html
#
# [Rd] R 4.1.0 is released
# https://mailman.stat.ethz.ch/pipermail/r-announce/2021/000670.html
#

# ./configure --help
# `configure' configures R 4.1.0 to adapt to many kinds of systems.
# Usage: ./configure [OPTION]... [VAR=VALUE]...
# To assign environment variables (e.g., CC, CFLAGS...), specify them as
# VAR=VALUE.  See below for descriptions of some of the useful variables.
# Defaults for the options are specified in brackets.
# Configuration:
#   -h, --help              display this help and exit
#       --help=short        display options specific to this package
#       --help=recursive    display the short help of all the included packages
#   -V, --version           display version information and exit
#   -q, --quiet, --silent   do not print `checking ...' messages
#       --cache-file=FILE   cache test results in FILE [disabled]
#   -C, --config-cache      alias for `--cache-file=config.cache'
#   -n, --no-create         do not create output files
#       --srcdir=DIR        find the sources in DIR [configure dir or `..']
# Installation directories:
#   --prefix=PREFIX         install architecture-independent files in PREFIX
#                           [/usr/local]
#   --exec-prefix=EPREFIX   install architecture-dependent files in EPREFIX
#                           [PREFIX]
# By default, `make install' will install all the files in
# `/usr/local/bin', `/usr/local/lib' etc.  You can specify
# an installation prefix other than `/usr/local' using `--prefix',
# for instance `--prefix=$HOME'.
# For better control, use the options below.
# Fine tuning of the installation directories:
#   --bindir=DIR            user executables [EPREFIX/bin]
#   --sbindir=DIR           system admin executables [EPREFIX/sbin]
#   --libexecdir=DIR        program executables [EPREFIX/libexec]
#   --sysconfdir=DIR        read-only single-machine data [PREFIX/etc]
#   --sharedstatedir=DIR    modifiable architecture-independent data [PREFIX/com]
#   --localstatedir=DIR     modifiable single-machine data [PREFIX/var]
#   --libdir=DIR            object code libraries [EPREFIX/lib]
#   --includedir=DIR        C header files [PREFIX/include]
#   --oldincludedir=DIR     C header files for non-gcc [/usr/include]
#   --datarootdir=DIR       read-only arch.-independent data root [PREFIX/share]
#   --datadir=DIR           read-only architecture-independent data [DATAROOTDIR]
#   --infodir=DIR           info documentation [DATAROOTDIR/info]
#   --localedir=DIR         locale-dependent data [DATAROOTDIR/locale]
#   --mandir=DIR            man documentation [DATAROOTDIR/man]
#   --docdir=DIR            documentation root [DATAROOTDIR/doc/R]
#   --htmldir=DIR           html documentation [DOCDIR]
#   --dvidir=DIR            dvi documentation [DOCDIR]
#   --pdfdir=DIR            pdf documentation [DOCDIR]
#   --psdir=DIR             ps documentation [DOCDIR]
# R installation directories:
#   --libdir=DIR        R files to R_HOME=DIR/R [EPREFIX/$LIBnn]
#     rdocdir=DIR       R doc files to DIR      [R_HOME/doc]
#     rincludedir=DIR   R include files to DIR  [R_HOME/include]
#     rsharedir=DIR     R share files to DIR    [R_HOME/share]
# X features:
#   --x-includes=DIR    X include files are in DIR
#   --x-libraries=DIR   X library files are in DIR
# System types:
#   --build=BUILD     configure for building on BUILD [guessed]
#   --host=HOST       cross-compile to build programs to run on HOST [BUILD]
# Optional Features:
#   --disable-option-checking  ignore unrecognized --enable/--with options
#   --disable-FEATURE       do not include FEATURE (same as --enable-FEATURE=no)
#   --enable-FEATURE[=ARG]  include FEATURE [ARG=yes]
#   --enable-R-profiling    attempt to compile support for Rprof() [yes]
#   --enable-memory-profiling
#                           attempt to compile support for Rprofmem(),
#                           tracemem() [no]
#   --enable-R-framework[=DIR]
#                           macOS only: build R framework (if possible), and
#                           specify its installation prefix [no,
#                           /Library/Frameworks]
#   --enable-R-shlib        build the shared/dynamic library 'libR' [no]
#   --enable-R-static-lib   build the static library 'libR.a' [no]
#   --enable-BLAS-shlib     build BLAS into a shared/dynamic library [perhaps]
#   --enable-maintainer-mode
#                           enable make rules and dependencies not useful (and
#                           maybe confusing) to the casual installer [no]
#   --enable-strict-barrier provoke compile error on write barrier violation
#                           [no]
#   --enable-prebuilt-html  build static HTML help pages [no]
#   --enable-lto            enable link-time optimization [no]
#   --enable-java           enable Java [yes]
#   --enable-byte-compiled-packages
#                           byte-compile base and recommended packages [yes]
#   --enable-static[=PKGS]  (libtool) build static libraries [default=no]
#   --enable-shared[=PKGS]  (libtool) build shared libraries [default=yes]
#   --enable-fast-install[=PKGS]
#                           (libtool) optimize for fast installation
#                           [default=yes]
#   --disable-libtool-lock  avoid locking (might break parallel builds)
#   --enable-long-double    use long double type [yes]
#   --disable-openmp        do not use OpenMP
#   --disable-largefile     omit support for large files
#   --disable-nls           do not use Native Language Support
#   --disable-rpath         do not hardcode runtime library paths
# Optional Packages:
#   --with-PACKAGE[=ARG]    use PACKAGE [ARG=yes]
#   --without-PACKAGE       do not use PACKAGE (same as --with-PACKAGE=no)
#   --with-blas             use system BLAS library (if available), or specify
#                           it [no]
#   --with-lapack           use system LAPACK library (if available), or specify
#                           it [no]
#   --with-readline         use readline library [yes]
#   --with-pcre2            use PCRE2 library (if available) [yes]
#   --with-pcre1            use PCRE1 library (if available and PCRE2 is not)
#                           [yes]
#   --with-aqua             macOS only: use Aqua (if available) [yes]
#   --with-tcltk            use Tcl/Tk (if available), or specify its library
#                           dir [yes]
#   --with-tcl-config=TCL_CONFIG
#                           specify location of tclConfig.sh []
#   --with-tk-config=TK_CONFIG
#                           specify location of tkConfig.sh []
#   --with-cairo            use cairo (and pango) if available [yes]
#   --with-libpng           use libpng library (if available) [yes]
#   --with-jpeglib          use jpeglib library (if available) [yes]
#   --with-libtiff          use libtiff library (if available) [yes]
#   --with-system-tre       use system tre library (if available) [no]
#   --with-valgrind-instrumentation
#                           Level of additional instrumentation for Valgrind
#                           (0/1/2) [0]
#   --with-system-valgrind-headers
#                           use system valgrind headers (if available) [no]
#   --with-internal-tzcode  use internal time-zone code [no, yes on macOS]
#   --with-internal-towlower
#                           use internal code for towlower/upper [no, yes on
#                           macOS and Solaris]
#   --with-internal-iswxxxxx
#                           use internal iswprint etc. [no, yes on macOS,
#                           Solaris and AIX]
#   --with-internal-wcwidth use internal wcwidth [yes]
#   --with-recommended-packages
#                           use/install recommended R packages [yes]
#   --with-ICU              use ICU library (if available) [yes]
#   --with-static-cairo     allow for the use of static cairo libraries [no, yes
#                           on macOS]
#   --with-pic[=PKGS]       (libtool) try to use only PIC/non-PIC objects
#                           [default=use both]
#   --with-aix-soname=aix|svr4|both
#                           (libtool) shared library versioning (aka "SONAME")
#                           variant to provide on AIX, [default=aix].
#   --with-gnu-ld           assume the C compiler uses GNU ld [default=no]
#   --with-sysroot[=DIR]    Search for dependent libraries within DIR (or the
#                           compiler's sysroot if not specified).
#   --with-x                use the X Window System
#   --with-gnu-ld           assume the C compiler uses GNU ld [default=no]
#   --with-libpth-prefix[=DIR]  search for libpth in DIR/include and DIR/lib
#   --without-libpth-prefix     don't search for libpth in includedir and libdir
#   --with-included-gettext use the GNU gettext library included here [no]
#   --with-libintl-prefix[=DIR]  search for libintl in DIR/include and DIR/lib
#   --without-libintl-prefix     don't search for libintl in includedir and libdir
# Some influential environment variables:
#   R_PRINTCMD  command used to spool PostScript files to the printer
#   R_PAPERSIZE paper size for the local (PostScript) printer
#   R_BATCHSAVE set default behavior of R when ending a session
#   MAIN_CFLAGS additional CFLAGS used when compiling the main binary
#   SHLIB_CFLAGS
#               additional CFLAGS used when building shared objects
#   MAIN_FFLAGS additional FFLAGS used when compiling the main binary
#   SHLIB_FFLAGS
#               additional FFLAGS used when building shared objects
#   MAIN_LD     command used to link the main binary
#   MAIN_LDFLAGS
#               flags which are necessary for loading a main program which will
#               load shared objects (DLLs) at runtime
#   CPICFLAGS   special flags for compiling C code to be turned into a shared
#               object.
#   FPICFLAGS   special flags for compiling Fortran code to be turned into a
#               shared object.
#   SHLIB_LD    command for linking shared objects which contain object files
#               from a C or Fortran compiler only
#   SHLIB_LDFLAGS
#               special flags used by SHLIB_LD
#   DYLIB_LD    command for linking dynamic libraries which contain object files
#               from a C or Fortran compiler only
#   DYLIB_LDFLAGS
#               special flags used for make a dynamic library
#   CXXPICFLAGS special flags for compiling C++ code to be turned into a shared
#               object
#   SHLIB_CXXLD command for linking shared objects which contain object files
#               from the C++ compiler
#   SHLIB_CXXLDFLAGS
#               special flags used by SHLIB_CXXLD
#   TCLTK_LIBS  flags needed for linking against the Tcl and Tk libraries
#   TCLTK_CPPFLAGS
#               flags needed for finding the tcl.h and tk.h headers
#   MAKE        make command
#   TAR         tar command
#   R_BROWSER   default browser
#   R_PDFVIEWER default PDF viewer
#   BLAS_LIBS   flags needed for linking against external BLAS libraries
#   LAPACK_LIBS flags needed for linking against external LAPACK libraries
#   LIBnn       'lib' or 'lib64' for dynamic libraries
#   SAFE_FFLAGS Safe Fortran fixed-form compiler flags for e.g. dlamc.f
#   r_arch      Use architecture-dependent subdirs with this name
#   DEFS        C defines for use when compiling R
#   JAVA_HOME   Path to the root of the Java environment
#   R_SHELL     shell to be used for shell scripts, including 'R'
#   YACC        The `Yet Another Compiler Compiler' implementation to use.
#               Defaults to the first program found out of: `bison -y', `byacc',
#               `yacc'.
#   YFLAGS      The list of arguments that will be passed by default to $YACC.
#               This script will default YFLAGS to the empty string to avoid a
#               default value of `-d' given by some make applications.
#   PKG_CONFIG  path to pkg-config (or pkgconf) utility
#   PKG_CONFIG_PATH
#               directories to add to pkg-config's search path
#   PKG_CONFIG_LIBDIR
#               path overriding pkg-config's default search path
#   CC          C compiler command
#   CFLAGS      C compiler flags
#   LDFLAGS     linker flags, e.g. -L<lib dir> if you have libraries in a
#               nonstandard directory <lib dir>
#   LIBS        libraries to pass to the linker, e.g. -l<library>
#   CPPFLAGS    (Objective) C/C++ preprocessor flags, e.g. -I<include dir> if
#               you have headers in a nonstandard directory <include dir>
#   CPP         C preprocessor
#   FC          Fortran compiler command
#   FCFLAGS     Fortran compiler flags
#   CXX         C++ compiler command
#   CXXFLAGS    C++ compiler flags
#   CXXCPP      C++ preprocessor
#   OBJC        Objective C compiler command
#   OBJCFLAGS   Objective C compiler flags
#   LT_SYS_LIBRARY_PATH
#               User-defined run-time library search path.
#   CXX11       C++11 compiler command
#   CXX11STD    special flag for compiling and for linking C++11 code, e.g.
#               -std=c++11
#   CXX11FLAGS  C++11 compiler flags
#   CXX11PICFLAGS
#               special flags for compiling C++11 code to be turned into a
#               shared object
#   SHLIB_CXX11LD
#               command for linking shared objects which contain object files
#               from the C++11 compiler
#   SHLIB_CXX11LDFLAGS
#               special flags used by SHLIB_CXX11LD
#   CXX14       C++14 compiler command
#   CXX14STD    special flag for compiling and for linking C++14 code, e.g.
#               -std=c++14
#   CXX14FLAGS  C++14 compiler flags
#   CXX14PICFLAGS
#               special flags for compiling C++14 code to be turned into a
#               shared object
#   SHLIB_CXX14LD
#               command for linking shared objects which contain object files
#               from the C++14 compiler
#   SHLIB_CXX14LDFLAGS
#               special flags used by SHLIB_CXX14LD
#   CXX17       C++17 compiler command
#   CXX17STD    special flag for compiling and for linking C++17 code, e.g.
#               -std=c++17
#   CXX17FLAGS  C++17 compiler flags
#   CXX17PICFLAGS
#               special flags for compiling C++17 code to be turned into a
#               shared object
#   SHLIB_CXX17LD
#               command for linking shared objects which contain object files
#               from the C++17 compiler
#   SHLIB_CXX17LDFLAGS
#               special flags used by SHLIB_CXX17LD
#   CXX20       C++20 compiler command
#   CXX20STD    special flag for compiling and for linking C++20 code, e.g.
#               -std=c++20
#   CXX20FLAGS  C++20 compiler flags
#   CXX20PICFLAGS
#               special flags for compiling C++20 code to be turned into a
#               shared object
#   SHLIB_CXX20LD
#               command for linking shared objects which contain object files
#               from the C++20 compiler
#   SHLIB_CXX20LDFLAGS
#               special flags used by SHLIB_CXX20LD
#   XMKMF       Path to xmkmf, Makefile generator for X Window System
# Use these variables to override the choices made by `configure' or to help
# it to find libraries and programs with nonstandard names/locations.
# Report bugs to <https://bugs.r-project.org>.
# R home page: <https://www.r-project.org>.

if [ "${rgithubbincacheextracted}" == "false" ] && [ ! "${r}" == "none" ]
then
  loginfo "BEGIN R EXTRACT XOR CONFIGURE+BUILD+INSTALL"
  if [ ! -f "r-r${rversion}-${Platform}-${Configuration}-${compiler}.7z" ]
  then
    loginfo "BEGIN R CONFIGURE"
    #
    # all cases - better
    sed -i -e "s/-gdwarf-2/-ggdb -Og -g3 -fno-omit-frame-pointer/" ${rsource}/src/gnuwin32/fixed/etc/Makeconf
    loginfo                                                                    "cat ${rsource}/src/gnuwin32/fixed/etc/Makeconf | grep ggdb"
                                                                                cat ${rsource}/src/gnuwin32/fixed/etc/Makeconf | grep ggdb

    echo -e "\n"                                 >> ${rsource}/src/gnuwin32/fixed/etc/Makeconf
    echo '$(info $$DEBUG is [${DEBUG}])'         >> ${rsource}/src/gnuwin32/fixed/etc/Makeconf
    echo -e "\n"                                 >> ${rsource}/src/gnuwin32/fixed/etc/Makeconf
    echo '$(info $$DEBUGFLAG is [${DEBUGFLAG}])' >> ${rsource}/src/gnuwin32/fixed/etc/Makeconf
    echo -e "\n"                                 >> ${rsource}/src/gnuwin32/fixed/etc/Makeconf


    # better debugging
    cp ${rsource}/src/gnuwin32/MkRules.dist                                         ${rsource}/src/gnuwin32/MkRules.local
    echo -e                                                                 "\n" >> ${rsource}/src/gnuwin32/MkRules.local
    echo "G_FLAG = -ggdb -Og -g3 -fno-omit-frame-pointer"                        >> ${rsource}/src/gnuwin32/MkRules.local
    echo -e                                                                 "\n" >> ${rsource}/src/gnuwin32/MkRules.local
    loginfo                                                                   "tail ${rsource}/src/gnuwin32/MkRules.local"
                                                                               tail ${rsource}/src/gnuwin32/MkRules.local

    echo -e "\n"                           >> ${rsource}/src/gnuwin32/MkRules.local
    echo '$(info $$G_FLAG is [${G_FLAG}])' >> ${rsource}/src/gnuwin32/MkRules.local
    echo -e "\n"                           >> ${rsource}/src/gnuwin32/MkRules.local 

    echo -e "\n" >> ${rsource}/src/gnuwin32/MkRules.local

    echo "OPENMP = -fopenmp" >> ${rsource}/src/gnuwin32/MkRules.local

    echo "BUILD_HTML = YES"  >> ${rsource}/src/gnuwin32/MkRules.local

    echo "USE_ICU = YES" >> ${rsource}/src/gnuwin32/MkRules.local
    # NIX default (guessing here) from Mkrules.dist (not OOms MkRuiles.local.in)
    echo "ICU_LIBS = -lsicuin -lsicuuc -lsicudt -lstdc++" >> ${rsource}/src/gnuwin32/MkRules.local

    echo "USE_CAIRO = YES" >> ${rsource}/src/gnuwin32/MkRules.local
    echo "CAIRO_LIBS = \"-lcairo -lfreetype -lpng -lpixman-1 -lz -liconv -lgdi32 -lmsimg32\"" >> ${rsource}/src/gnuwin32/MkRules.local
    echo "CAIRO_CPPFLAGS = -I/usr/include/cairo" >> ${rsource}/src/gnuwin32/MkRules.local

    echo "USE_LIBCURL = YES" >> ${rsource}/src/gnuwin32/MkRules.local

    if [ "${Platform}" == "x64" ]
    then
      echo "CURL_LIBS = -lcurl -lrtmp -lssl -lssh2 -lcrypto -lgdi32 -lcrypt32 -lz -lws2_32 -lgdi32 -lcrypt32 -lwldap32 -lwinmm" >> ${rsource}/src/gnuwin32/MkRules.local
    fi

    if [ "${Platform}" == "x86" ]
    then
      echo "CURL_LIBS = -lcurl -lrtmp -lssl -lssh2 -lcrypto -lgdi32 -lcrypt32 -lz -lws2_32 -lgdi32 -lcrypt32 -lwldap32 -lwinmm -lidn" >> ${rsource}/src/gnuwin32/MkRules.local
    fi

    #
    echo "QPDF = /usr/"     >> ${rsource}/src/gnuwin32/MkRules.local
    loginfo               "cat ${rsource}/src/gnuwin32/MkRules.local | grep QPDF"
                           cat ${rsource}/src/gnuwin32/MkRules.local | grep QPDF
                           
    echo -e "\n"            >> ${rsource}/src/gnuwin32/MkRules.local

    #
    #  # if I want to use OpenBlas (hacking ATLAS on MSYS2)
    #  sed -i "s/-lf77blas -latlas\b/-lopenblas/" ${rsource}/configure
    #  loginfo                               cat "${rsource}/configure | grep openblas"
    #                                        cat  ${rsource}/configure | grep openblas
    #  #
    #  sed -i "s/-lf77blas -latlas\b/-lopenblas/" ${rsource}/src/extra/blas/Makefile.win
    #  loginfo                               "cat ${rsource}/src/extra/blas/Makefile.win | grep openblas"
    #                                         cat ${rsource}/src/extra/blas/Makefile.win | grep openblas
    #

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
    # TOO MUCH OUTPUT
    # loginfo "find ${rsource} -type f -print"
    # find ${rsource} -type f -print
    #
    if [ "${Configuration}" == "Release" ]
    then
      echo ""
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
      # undefined references everywhere - try compiling with "good platform choices"
      #
      ./configure --disable-rpath --enable-R-shlib --enable-BLAS-shlib=no --enable-java=no --without-readline --with-blas --with-lapack --without-x --prefix=${rroot} 2>&1 | tee config_interactive.log
      #
    fi
    loginfo "END   R CONFIGURE"
    loginfo "BEGIN R BUILD"
    if [ "${Configuration}" == "Release" ]
    then
      # make USE_ATLAS=YES ATLAS_PATH=/use/lib/
      make
    fi
    if [ "${Configuration}" == "Debug" ]
    then
      # https://cran.r-project.org/bin/windows/base/rw-FAQ.html#How-do-I-debug-code-that-I-have-compiled-and-dyn_002eload_002ded_003f
      # make USE_ATLAS=YES ATLAS_PATH=/use/lib/ DEBUG=T
      make DEBUG=T
      # failing to pickup my custom debugging  flags.  why??
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
