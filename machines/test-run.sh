#!/bin/bash
#Author Frank Font 2018
#License MIT

VERSIONINFO=20180702.1

echo Starting $0 v$VERSIONINFO $@
echo "USAGE $0 FOLDERNAME [TAG_NAME] [IMAGE_SOURCE_PREFIX] [USERNAME] [WHAT2RUN]"
echo

#Grab command line arguments
FOLDERNAME=$1
TAG_NAME=$2
IMAGE_SOURCE_PREFIX=$3
USERNAME=$4
WHAT2RUN=$5

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

RUN_PORTARGS=""
if [ ! -z "$PORT_MAPS" ]; then
    for ONEMAP in ${PORT_MAPS[@]}; do
        RUN_PORTARGS="$RUN_PORTARGS -p $ONEMAP "
    done
fi

if [ -z "${IMAGE_NAME}" ]; then
    echo "ERROR: Did NOT find IMAGE_NAME declared in $SETTINGSPATH"
    exit 2
fi

if [ -z "$TAG_NAME" ]; then
    TAG_NAME="latest"
fi
if [ -z "$IMAGE_SOURCE_PREFIX" ]; then
    IMAGE_SOURCE_PREFIX="local"
    FULL_IMAGE_REF="${IMAGE_SOURCE_PREFIX}/${IMAGE_NAME}:${TAG_NAME}"
fi

if [ "public" = "$IMAGE_SOURCE_PREFIX" ]; then
    #IMAGE_SOURCE_PREFIX=""
    FULL_IMAGE_REF="${IMAGE_NAME}:${TAG_NAME}"
else
    #IMAGE_SOURCE_PREFIX="${IMAGE_SOURCE_PREFIX}/"
    FULL_IMAGE_REF="${IMAGE_SOURCE_PREFIX}/${IMAGE_NAME}:${TAG_NAME}"
fi

RUN_USERARG=""
if [ ! -z "$USERNAME" ]; then
    RUN_USERARG=" --user $USERNAME"
fi

echo "... IMAGE NAME     = ${IMAGE_NAME}"
echo "... TAG NAME       = ${TAG_NAME}"
echo "... SOURCE PREFIX  = ${IMAGE_SOURCE_PREFIX}"
echo "... FULL IMAGE REF = ${FULL_IMAGE_REF}"
if [ -z "$RUN_USERARG" ]; then
    echo "... RUN AS USER    = <image default>"
else
    echo "... RUN AS USER    = $USERNAME"
fi
if [ -z "$RUN_PORTARGS" ]; then
    echo "... EXPOSED PORTS  = NONE"
else
    echo "... EXPOSED PORTS  = ${PORT_MAPS[*]}"
fi
if [ -z "$WHAT2RUN" ]; then
    echo "... WHAT2RUN       = DEFAULT COMMAND"
else
    echo "... WHAT2RUN       = ${WHAT2RUN}"
fi

#Enable us to run command in subshell but redirect output to this shell
exec 3>&1 # Alias stdout
exec 4>&2 # Alias stderr
function runInSubshell() 
{ 
    local CMD=$@
    echo "CMD=$CMD"
    $(eval $CMD 1>&3 2>&4 &)
}

CMD="docker run ${RUN_USERARG} ${RUN_PORTARGS} ${FULL_IMAGE_REF} ${WHAT2RUN}"
runInSubshell $CMD

echo
echo Finished $0 $@
echo


