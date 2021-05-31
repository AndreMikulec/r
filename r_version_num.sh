
set -v -x

cd "$(dirname "$0")"

# remove first whitespace and all the way through the end of the line 
sed -i -r -e 's/\s+.*$//g' $(cygpath "${rsource}")/VERSION

cp $(cygpath "${rsource}")/VERSION ${APPVEYOR_BUILD_FOLDER}/r_version_num.txt
cat                                ${APPVEYOR_BUILD_FOLDER}/r_version_num.txt

set +v +x
