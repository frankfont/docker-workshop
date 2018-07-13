#!/bin/bash
#Author Frank Font 2018
#License MIT

VERSIONINFO=20180702.2

echo Starting $0 v$VERSIONINFO $@
echo "USAGE $0 FOLDERNAME [TAG_NAME] [IMAGE_SOURCE_PREFIX] [USERNAME]"
echo

#Grab command line arguments
FOLDERNAME=$1
TAG_NAME=$2
IMAGE_SOURCE_PREFIX=$3
USERNAME=$4

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

#Enable us to run command in subshell but redirect output to this shell
exec 3>&1 # Alias stdout
exec 4>&2 # Alias stderr

CONTAINERID="TBD"
function findExistingContainerID()
{
    FIND=${FULL_IMAGE_REF}
    #echo "docker container ps | awk -v aaa=${FULL_IMAGE_REF} '$2 == aaa {print $1}'"
    CONTAINERID=$(docker container ps | awk -v aaa=${FIND} '$2 == aaa {print $1}')
    if [ -z "$CONTAINERID" ]; then
        echo "$FIND not currently running"
    else
        echo "$FIND currently running as $CONTAINERID"
        docker ps | grep $CONTAINERID
    fi
}

function terminalNewContainer() 
{ 
    echo "Opening terminal into a NEW container"
    local CMD="docker run -ti ${RUN_USERARG} ${RUN_PORTARGS} ${FULL_IMAGE_REF} /bin/bash"
    echo "CMD=$CMD"
    $(eval $CMD 1>&3 2>&4)
}

function terminalExistingContainer()
{
    local CONTAINERID=$1
    echo "Opening terminal into existing container"
    local CMD="docker exec -ti ${RUN_USERARG} ${CONTAINERID} /bin/bash"
    echo "CMD=$CMD"
    $(eval $CMD 1>&3 2>&4)
}

findExistingContainerID
if [ ! -z "$CONTAINERID" ]; then
    terminalExistingContainer "$CONTAINERID"
else
    terminalNewContainer
fi

echo
echo Finished $0 $@
echo


