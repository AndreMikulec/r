
set -v -x

cd "$(dirname "$0")"

curl -o THROWAWAYFILE --head --fail -L ${rgithubbincacheurl}
if [ $? -eq 0 ]
then
  echo false > $(cygpath ${APPVEYOR_BUILD_FOLDER})/rgithubbincachefailingfound.txt
else
  echo true  > $(cygpath ${APPVEYOR_BUILD_FOLDER})/rgithubbincachefailingfound.txt
fi

set +v +x