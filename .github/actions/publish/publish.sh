#!/bin/bash

set -e

print_usage_instructions() {
    echo "Usage: bash publish.sh <version>";
    echo "";
    echo "Example use:";
    echo "  bash publish.sh 3.1.1";
    exit 1
}

if [ $# -eq 0 ]; then
    print_usage_instructions
fi

version="$1"

# We will only handle versions >= v1 in the format {MAJOR}.{MINOR}?.{PATCH}?
#   capture 1: major number
#   capture 2: minor number with dot
#   capture 3: minor number without dot
#   capture 4: patch number with dot
#   capture 5: patch number without dot
VERSION_REGEX="^([1-9][0-9]*)(\.(0|[1-9][0-9]*)){0,1}(\.(0|[1-9][0-9]*)){0,1}$"
PUBLISHED='false'

if [[ "$version" =~ $VERSION_REGEX ]] ; then
    majorTag="v${BASH_REMATCH[1]}"
    minorTag="$majorTag.${BASH_REMATCH[3]:-0}"
    patchTag="$minorTag.${BASH_REMATCH[5]:-0}"
    tagsToUpdate=("$majorTag" "$minorTag")
else
    echo "Provided version does not match the format \"{MAJOR}.{MINOR}?.{PATCH}?\". Skipping tag updates."
    exit 0
fi

if [ "$(git tag -l "$patchTag")" ]; then
    echo "Version $patchTag has already been released! Skipping tag updates."
    exit 0
else 
    echo "Creating tag: $patchTag"
    git tag -a "$patchTag" -m " Release $patchTag"
    git push origin "$patchTag"
    PUBLISHED='true'
fi

for tag in "${tagsToUpdate[@]}"; do
    message="Release $patchTag"

    if [ "$(git tag -l "$tag")" ]; then
        echo "Updating tag: $tag"
        message="Update to $patchTag"
    else
        echo "Creating tag: $tag"
    fi

    git tag -fa "$tag" -m "$message"
    git push origin "$tag" --force
done

echo "::set-output name=PUBLISHED::$PUBLISHED"