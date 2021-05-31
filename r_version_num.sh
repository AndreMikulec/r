
set -v -x

cd "$(dirname "$0")"

# remove first whitespace and all the way through the end of the line 
sed -i -r -e 's/\s+.*$//g' $(cygpath "${rsource}")/VERSION

# remove the only and last empty line (if any)
echo -n $(cat $(cygpath $(cygpath "${rsource}")/VERSION) > ${APPVEYOR_BUILD_FOLDER}/r_version_num.txt

set +v +x
