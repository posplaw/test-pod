# .xcworkspace file we're building
PROJ=$1
echo "\nEntering workspace '$PROJ.xcworkspace'\n"

# output destination
DESTINATION=".build/frameworks/$PROJ.xcframework"

# desired platforms in final .xcframework
TARGETS=()
TARGETS+=("iOS")
TARGETS+=("iOS Simulator")
#TARGETS+=("macOS")
#TARGETS+=("Mac Catalyst")

ARCHS=("ios-arm64" "ios-arm64_x86_64-simulator")

# clear working directory
rm -rf .build

# store prebuilt archive paths
ARCHIVES=()
ARCHIVES_SCHEMES=()

# building archive for given workspace, scheme and target
build_archive () {
    TARGET=$1
        
    ARCHIVE_NAME=$(echo "$PROJ-$TARGET" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
    ARCHIVE_PATH=".build/archives/$ARCHIVE_NAME"
    
    xcodebuild archive \
        -workspace "$PROJ".xcworkspace \
        -scheme $PROJ \
        -destination "generic/platform=$TARGET" \
        -archivePath "$ARCHIVE_PATH" \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
        SKIP_INSTALL=NO
        
    ARCHIVES+=($ARCHIVE_PATH)
    ARCHIVES_SCHEMES+=($SCHEME)
}

# build all targets
for i in ${!TARGETS[@]};
do
    TARGET=${TARGETS[$i]}
    echo "Building scheme '$PROJ' for target '$TARGET'"
    build_archive "$TARGET" >> /dev/null
done

# remove framework if exists
rm -rf $DESTINATION

# prepare archive includes in framework
echo "Building workspace to $DESTINATION"

ARCHIVE_PARAMS=()
for i in ${!ARCHIVES[@]};
do
    ARCHIVE_PATH=${ARCHIVES[$i]}
    ARCHIVE_PARAMS+=("-archive $ARCHIVE_PATH.xcarchive -framework $PROJ.framework")
done

PARAMS_JOINED=$(IFS=" "; echo "${ARCHIVE_PARAMS[*]}")
xcodebuild -create-xcframework $PARAMS_JOINED -output $DESTINATION >> /dev/null

# grab xcframework directories from dependencies list
echo "\nLooking for static .xcframework dependencies..."
for sub in "Pods"/*
do
    NAME="${sub##*/}"
    XC="Pods/$NAME/$NAME.xcframework"
    if [ -d "$XC" ]; then
        echo "Found '$XC', attaching to archive"
        cp -r "$XC" ".build/frameworks/$NAME.xcframework"
    fi
done

# strip unneeded archs
ARCHS_INCLUDED=$(IFS=", "; echo "${ARCHS[*]}")
echo "\nAllowed architectures: $ARCHS_INCLUDED"

STRIP_SCRIPT=".build/strip.rb"

strip_plist () {
    # write script
    if [ ! -f "$STRIP_SCRIPT" ]; then
        touch "$STRIP_SCRIPT"
        echo "require 'xcodeproj'" >> "$STRIP_SCRIPT"
        echo "plist = Xcodeproj::Plist.read_from_path(ARGV[0])" >> "$STRIP_SCRIPT"
        echo "plist['AvailableLibraries'].delete_if { |x| x['LibraryIdentifier'] == ARGV[1] }" >> "$STRIP_SCRIPT"
        echo "Xcodeproj::Plist.write_to_path(plist, ARGV[0])" >> "$STRIP_SCRIPT"
    fi
    
    # exec
    ruby $STRIP_SCRIPT $1 $2
}

    FRAMEWORK_DIRS=()
for lib in ".build/frameworks"/*
do
    NAME="${lib##*/}"
    XC=".build/frameworks/$NAME"
    
    for framework in "$XC"/*
    do
        FILE="${framework##*/}"
        if [ "$FILE" = "Info.plist" ]; then
            continue
        fi
        
        OK="false"
        for i in ${!ARCHS[@]};
        do
            ARCH=${ARCHS[$i]}
            if [ "$ARCH" = "$FILE" ]; then
                OK="true"
                break
            fi
        done
                
        if [ "$OK" = "false" ]; then
            echo "Stripping '$FILE' arch from '$NAME'"
            strip_plist "$XC/Info.plist" $FILE # remove record from plist
            rm -rf "$XC/$FILE" # delete sub-framework with unwanted arch
        fi
    done
    
    FRAMEWORK_DIRS+=($NAME)
done

# archive
echo "\nArchiving xcframeworks"

cd ".build/frameworks"
XCS=$(IFS=" "; echo "${FRAMEWORK_DIRS[*]}")

zip -r ../final.zip $XCS >> /dev/null
cd ../../
mv .build/final.zip "./$PROJ.zip"

# finalize
echo "Clearing caches."
rm -rf .build "$DESTINATION"
echo "\nBye."
