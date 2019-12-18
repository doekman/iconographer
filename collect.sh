#!/usr/bin/env bash

function get_domain {
    # Modelled after AppleScript's from-enumeration
    case "$1" in
        /Users/*) echo "user";;
        /System/*) echo "system";;
        /Applications/* | /Library/*) echo "local";;
        /private/*) echo "private";;
        *) echo "other";;
    esac
}

function package_name {
    folder="$1"
    while [[ ${#folder} -gt 1 ]]; do
        if mdls -name kMDItemContentTypeTree "$folder" | grep 'com.apple.package' > /dev/null; then
            bundle_id="$(mdls -raw -name kMDItemCFBundleIdentifier "$folder")"
            #content_type="$(mdls -raw -name kMDItemContentType "$folder")"
            if [[ $bundle_id == "(null)" ]]; then
                basename "$folder"
            else
                echo "$bundle_id"
            fi
            break
        fi
        folder="$(dirname "$folder")"
    done
}

SEARCH_BASE=${1:-$HOME/prj}
BUILD_DB=${2:-0}
echo "Hunting for icons in: $SEARCH_BASE (BUILD_DB:$BUILD_DB)"

cd "$(dirname "$0")" || exit 1
SCRIPT_FOLDER="$(pwd)"
ICON_BASE="$SCRIPT_FOLDER/icons"
((count=0))
((new_count=0))

mkdir -p "$ICON_BASE"
IFS=$'\n'
while IFS= read -r -d '' file; do
    if [[ $file != "$SCRIPT_FOLDER"/* ]]; then
        ((count++))
        sha256=$(shasum -a 256 -b "$file" | awk '{print $1}')
        if [[ ! -f $ICON_BASE/$sha256.icns ]]; then
            ((new_count++))
            cp "$file" "$ICON_BASE/$sha256.icns"
        fi
        if [[ $BUILD_DB == 1 ]]; then
            filename=$(basename "$file")
            domain=$(get_domain "$file")
            in_package=$(package_name "$file")
            ./icon-db.sh "$sha256" "$filename" "$domain" "$in_package" --pretty-print
            echo "$count. $filename - $domain - $in_package - $sha256 ($file)"
        else
            echo "$count. $file"
        fi
    fi
done <   <(find "$SEARCH_BASE" -type f -name '*.icns' -print0)

echo "Found $count files and added $new_count new unique ones"


### find zonder icon-db in $HOME ##########################
# Found 332 files and added 172 new unique ones
#real	0m23.277s
#user	0m7.433s
#sys	0m12.261s

### find met icon-db in $HOME ############################
# Found 332 files and added 172 new unique ones
#real	1m45.710s
#user	0m29.213s
#sys	0m32.542s
# 5 keer zo traag...

## mdfind zonder icon-db in $HOME ########################
# Found 49 files and added 47 new unique ones
#real	0m2.002s
#user	0m1.037s
#sys	0m0.534s
# Vindt minder

## mdfind met icon-db in $HOME ########################
# Found 49 files and added 47 new unique ones
#real	0m14.715s
#user	0m4.284s
#sys	0m3.716s
# 7x zo traag
