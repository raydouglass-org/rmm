#!/bin/bash
########################
# RMM Version Updater #
########################

## Usage
# bash update-version.sh <type>
#     where <type> is either `major`, `minor`, `patch`

set -e

# Grab argument for release type
RELEASE_TYPE=$1

# Get current version and calculate next versions
CURRENT_TAG=`git tag | grep -xE 'v[0-9\.]+' | sort --version-sort | tail -n 1 | tr -d 'v'`
CURRENT_MAJOR=`echo $CURRENT_TAG | awk '{split($0, a, "."); print a[1]}'`
CURRENT_MINOR=`echo $CURRENT_TAG | awk '{split($0, a, "."); print a[2]}'`
CURRENT_PATCH=`echo $CURRENT_TAG | awk '{split($0, a, "."); print a[3]}'`
NEXT_MAJOR=$((CURRENT_MAJOR + 1))
NEXT_MINOR=$((CURRENT_MINOR + 1))
NEXT_PATCH=$((CURRENT_PATCH + 1))
NEXT_FULL_TAG=""
NEXT_SHORT_TAG=""

# Determine release type
if [ "$RELEASE_TYPE" == "major" ]; then
  NEXT_FULL_TAG="${NEXT_MAJOR}.0.0"
  NEXT_SHORT_TAG="${NEXT_MAJOR}.0"
elif [ "$RELEASE_TYPE" == "minor" ]; then
  NEXT_FULL_TAG="${CURRENT_MAJOR}.${NEXT_MINOR}.0"
  NEXT_SHORT_TAG="${CURRENT_MAJOR}.${NEXT_MINOR}"
elif [ "$RELEASE_TYPE" == "patch" ]; then
  NEXT_FULL_TAG="${CURRENT_MAJOR}.${CURRENT_MINOR}.${NEXT_PATCH}"
  NEXT_SHORT_TAG="${CURRENT_MAJOR}.${CURRENT_MINOR}"
else
  echo "Incorrect release type; use 'major', 'minor', or 'patch' as an argument"
  exit 1
fi

echo "Preparing '$RELEASE_TYPE' release [$CURRENT_TAG -> $NEXT_FULL_TAG]"

# Inplace sed replace; workaround for Linux and Mac
function sed_runner() {
    sed -i.bak ''"$1"'' $2 && rm -f ${2}.bak
}

sed_runner 's/'"  VERSION .*"'/'"  VERSION ${NEXT_FULL_TAG} LANGUAGES"'/g' CMakeLists.txt

sed_runner 's/version=.*/version=\"'"${NEXT_FULL_TAG}"'\",/g' python/setup.py

sed_runner 's/'"PROJECT_NUMBER         = .*"'/'"PROJECT_NUMBER         = ${NEXT_SHORT_TAG}"'/g' doxygen/Doxyfile

sed_runner 's/'"version =.*"'/'"version = \"${NEXT_SHORT_TAG}\""'/g' python/docs/conf.py
sed_runner 's/'"release =.*"'/'"release = \"${NEXT_FULL_TAG}\""'/g' python/docs/conf.py
