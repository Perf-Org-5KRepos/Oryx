#!/bin/bash
set -e

# https://medium.com/@Drew_Stokes/bash-argument-parsing-54f3b81a6a8f
PARAMS=""
while (( "$#" )); do
  case "$1" in
    -d|--dir)
      parentDir=$2
      shift 2
      ;;
    -p|--platform)
      platform=$2
      shift 2
      ;;
    -v|--version)
      version=$2
      shift 2
      ;;
    -u|--base-url)
      storageBaseUrl=$2
      shift 2
      ;;
    --) # end argument parsing
      shift
      break
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done
# set positional arguments in their proper place
eval set -- "$PARAMS"

function printUsage() {
    echo "Usage: installPlatform.sh -p <platform-name> -v <platform-version> -d <directory-to-install> -u <storage-url>"
    exit 1
}

defaultInstallationRootDir="/tmp/oryx/platforms"
if [ -z "$platform" ]; then
    echo "Platform name is required."
    printUsage
fi

if [ -z "$version" ]; then
    echo "Platform version is required."
    printUsage
fi

if [ -z "$parentDir" ]; then
    parentDir="$defaultInstallationRootDir/$platform/$version"
fi

if [ -z "$storageBaseUrl" ]; then
    storageBaseUrl="https://oryxsdksdev.blob.core.windows.net"
fi

fileName="$platform-$version.tar.gz"
fullInstallationPath="$parentDir/$version"

PLATFORM_SETUP_START=$SECONDS
echo
echo "Downloading and extracting '$platform' version '$version' to '$fullInstallationPath'..."
rm -rf "$fullInstallationPath"
mkdir -p "$fullInstallationPath"
cd "$fullInstallationPath"
PLATFORM_BINARY_DOWNLOAD_START=$SECONDS
curl \
    -D headers.txt \
    -SL "$storageBaseUrl/$platform/$fileName" \
    --output "$version.tar.gz" \
    >/dev/null 2>&1
PLATFORM_BINARY_DOWNLOAD_ELAPSED_TIME=$(($SECONDS - $PLATFORM_BINARY_DOWNLOAD_START))
echo "Downloaded in $PLATFORM_BINARY_DOWNLOAD_ELAPSED_TIME sec(s)."
echo "Verifying checksum..."
headerName="x-ms-meta-checksum"
checksumHeader=$(cat headers.txt | grep -i $headerName: | tr -d '\r')
checksumHeader=$(echo $checksumHeader | tr '[A-Z]' '[a-z]')
checksumValue=${checksumHeader#"$headerName: "}
rm -f headers.txt
echo "$checksumValue $version.tar.gz" | sha512sum -c - >/dev/null 2>&1
echo Extracting contents...
tar -xzf $version.tar.gz -C .
rm -f $version.tar.gz
PLATFORM_SETUP_ELAPSED_TIME=$(($SECONDS - $PLATFORM_SETUP_START))
echo "Done in $PLATFORM_SETUP_ELAPSED_TIME sec(s)."
echo
echo > $fullInstallationPath/.oryx-sdkdownload-sentinel