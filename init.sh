
cd "$(dirname "$0")"

# mypaint/windows/msys2-build.sh
# https://github.com/mypaint/mypaint/blob/4141a6414b77dcf3e3e62961f99b91d466c6fb52/windows/msys2-build.sh
#
# ANSI control codes
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

loginfo() {
  # set +v +x
  echo -ne "${CYAN}"
  echo -n "$@"
  echo -e "${NC}"
  # set -v -x
}

logok() {
  # set +v +x
  echo -ne "${GREEN}"
  echo -n "$@"
  echo -e "${NC}"
  # set -v -x
}

logerr() {
  # set +v +x
  echo -ne "${RED}ERROR: "
  echo -n "$@"
  echo -e "${NC}"
  # set -v -x
}

logok "BEGIN init.sh"


loginfo "uname -a $(uname -a)"

export R_HOME=$(cygpath "${R_HOME}")
loginfo "R_HOME ${R_HOME}"

#
# "rsource" variable
# is only used about a custom PostgreSQL build (not an MSYS2 or CYGWIN already compiled binary)
# 

export rsource=$(cygpath "${rsource}")
loginfo "rsource ${rsource}"

export APPVEYOR_BUILD_FOLDER=$(cygpath "${APPVEYOR_BUILD_FOLDER}")
# echo $APPVEYOR_BUILD_FOLDER

# 
# echo ${MINGW_PREFIX}
# /mingw64

if [ ! "${r}" == "none" ]
then
  export rroot=$(cygpath "${rroot}")
else
  if [ "${compiler}" == "msys2" ]
  then
    export rroot=${MINGW_PREFIX}
  fi
  # cygwin override
  if [ "${compiler}" == "cygwin" ]
  then
    export rroot=/usr
  fi
fi
loginfo "rroot $rroot"

# R in msys2 does sub architectures
if [ "${compiler}" == "msys2" ]
then
  export PATH=${R_HOME}/bin${R_ARCH}:${PATH}
else 
  # cygwin does-not-do R sub architectures
  export PATH=${R_HOME}/bin:${PATH}
fi
loginfo "R_HOME is in the PATH $(echo ${PATH})"

logok "END   init.sh"