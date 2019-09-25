#!/bin/bash
# --------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT license.
# --------------------------------------------------------------------------------------------

set -ex

declare -r REPO_DIR=$( cd $( dirname "$0" ) && cd .. && pwd )

source $REPO_DIR/build/__variables.sh

artifactFileName="$1"

imageName="buildpack-deps:stretch"
docker pull "$imageName" 
docker tag "$imageName" "oryx-$imageName-$IMAGE_TAG"
echo "$imageName-$IMAGE_TAG" >> "$artifactFileName"

imageName="buildpack-deps:stretch-curl"
docker pull "$imageName" 
docker tag "$imageName" "oryx-$imageName-$IMAGE_TAG"
echo "$imageName-$IMAGE_TAG" >> "$artifactFileName"
