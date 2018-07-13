#!/bin/bash
#Author Frank Font 2018
#License MIT

VERSIONINFO=20180630.2

echo Starting $0 v$VERSIONINFO $@
echo "USAGE $0 FOLDERNAME [TAG_NAME]"

#Grab command line arguments
FOLDERNAME=$1
TAG_NAME=$2

PWD=$(pwd)

if [ -z "$FOLDERNAME" ]; then
    echo "ERROR: Missing required foldername"
    echo "Folders available at $PWD are as follows ..."
    ls -d */
    echo
    exit 2
fi
if [ ! -d "$FOLDERNAME" ]; then
    echo "ERROR: Did not find folder named $FOLDERNAME"
    echo "Folders available at $PWD are as follows ..."
    ls -d */
    echo
    exit 2
fi

SETTINGSPATH="$FOLDERNAME/mysettings.env"
if [ ! -f "$SETTINGSPATH" ]; then
    echo "ERROR: Did not find $SETTINGSPATH from $PWD"
    exit
fi

source $SETTINGSPATH

if [ -z "${IMAGE_NAME}" ]; then
    echo "ERROR: Did NOT find IMAGE_NAME declared in $SETTINGSPATH"
    exit 2
fi

if [ -z "$TAG_NAME" ]; then
    TAG_NAME="latest"
fi

echo "... IMAGE NAME = ${IMAGE_NAME}"
echo "... TAG NAME   = ${TAG_NAME}"

#Enable us to run command in subshell but redirect output to this shell
exec 3>&1 # Alias stdout
exec 4>&2 # Alias stderr
function runInSubshell() 
{ 
    local CMD=$@
    echo "CMD=$CMD"
    $(eval $CMD 1>&3 2>&4)
}

#See https://docs.docker.com/engine/reference/commandline/build/
CMD="cd $FOLDERNAME && docker build --rm -t local/${IMAGE_NAME}:${TAG_NAME} ."
runInSubshell $CMD

echo
echo Finished $0 $@
echo