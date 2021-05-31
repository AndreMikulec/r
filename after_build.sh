
cd "$(dirname "$0")"

. ./init.sh

logok "BEGIN after_build.sh"

# set -v -x -e
set -e

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

# set +v +x +e
set +e

logok "END   after_build.sh"