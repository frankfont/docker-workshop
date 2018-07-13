#!/bin/bash
#Author Frank Font 2018
#License MIT

VERSIONINFO=20180630.2

echo Starting $0 v$VERSIONINFO $@
echo "USAGE $0 FOLDERNAME TAG_NAME IMAGE_SOURCE_PREFIX IMAGE_TARGET_PREFIX"
echo

#Grab command line arguments
FOLDERNAME=$1
TAG_NAME=$2
IMAGE_SOURCE_PREFIX=$3
IMAGE_TARGET_PREFIX=$4

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

WARNCOUNT=0
if [ -z "$TAG_NAME" ]; then
    TAG_NAME="latest"
    echo "WARNING: Missing TAG_NAME! Assuming value '$TAG_NAME'"
    WARNCOUNT=$(($WARNCOUNT+1))
fi
if [ -z "$IMAGE_SOURCE_PREFIX" ]; then
    SRC_IMAGE_NAME="${IMAGE_NAME}"
    echo "WARNING: Missing IMAGE_SOURCE_PREFIX! Assuming blank value."
    echo "         Normal value is usually 'local'."
    WARNCOUNT=$(($WARNCOUNT+1))
else
    SRC_IMAGE_NAME="${IMAGE_SOURCE_PREFIX}/${IMAGE_NAME}"
fi
if [ -z "$IMAGE_TARGET_PREFIX" ]; then
    TRG_IMAGE_NAME="${IMAGE_NAME}"
    echo "WARNING: Missing IMAGE_TARGET_PREFIX! Assuming blank value."
    echo "         Normal value is usually your docker.com login name."
    WARNCOUNT=$(($WARNCOUNT+1))
else
    TRG_IMAGE_NAME="${IMAGE_TARGET_PREFIX}/${IMAGE_NAME}"
fi

echo
echo "... IMAGE NAME    = ${IMAGE_NAME}"
echo "... TAG NAME      = ${TAG_NAME}"
echo "... SOURCE PREFIX = ${IMAGE_SOURCE_PREFIX}"
echo "... TARGET PREFIX = ${IMAGE_TARGET_PREFIX}"
echo

#FOUND=$(docker image ls | awk '$2 == "${TAG_NAME}" {print $1}' | grep "${IMAGE_NAME}")
if [ -z "${IMAGE_SOURCE_PREFIX}" ]; then
    FOUND=$(docker image ls | awk -v aaa=${TAG_NAME} '$2 == aaa {print $1}' | grep "${IMAGE_NAME}")
    PREFIXNOTE="NO IMAGE PREFIX"
else
    FOUND=$(docker image ls | awk -v aaa=${TAG_NAME} '$2 == aaa {print $1}' | awk -v ppp=${IMAGE_SOURCE_PREFIX} -F "/" '$1 == ppp {print "/"$2"/"$3"/"}' | grep "${IMAGE_NAME}")
    PREFIXNOTE="image prefix '${IMAGE_SOURCE_PREFIX}'"
fi
if [ -z "$FOUND" ]; then
    echo "Did not find any existing image with name '${IMAGE_NAME}' and tag '${TAG_NAME}' and ${PREFIXNOTE}!"
    echo "Check yourself using the 'docker image ls' command!"
    echo
    exit 2
fi

function docker_tag()
{
    local SRC_IMAGE_NAME=$1
    local TRG_IMAGE_NAME=$2
    local TAG_NAME=$3

    CMD_TAG="docker tag ${SRC_IMAGE_NAME}:${TAG_NAME} ${TRG_IMAGE_NAME}:${TAG_NAME}"
    echo $CMD_TAG
    eval $CMD_TAG
    RC=$?
    if [ $RC -ne 0 ]; then
        echo "Failed with return code $RC"
        exit 2
    fi
    echo
}

if [ ! -z "${IMAGE_SOURCE_PREFIX}" ]; then
    echo "Creating a NON-'$IMAGE_SOURCE_PREFIX' PREFIXED image for us to push ..."
    docker_tag "${SRC_IMAGE_NAME}" "${TRG_IMAGE_NAME}" "${TAG_NAME}"
else
    if [ ! "${IMAGE_SOURCE_PREFIX}" = "${IMAGE_TARGET_PREFIX}" ]; then
        echo "Creating a '$IMAGE_TARGET_PREFIX' PREFIXED image for us to push ..."
        docker_tag "${SRC_IMAGE_NAME}" "${TRG_IMAGE_NAME}" "${TAG_NAME}"
    fi
fi

echo
echo "CURRENT IMAGES..."
docker image ls | grep "${IMAGE_NAME}" | grep "${TAG_NAME}"
echo

echo "READY TO PUSH! (With $WARNCOUNT warnings)"
echo
echo "... IMAGE NAME    = ${IMAGE_NAME}"
echo "... TAG NAME      = ${TAG_NAME}"
echo "... SOURCE PREFIX = ${IMAGE_SOURCE_PREFIX}"
echo "... TARGET PREFIX = ${IMAGE_TARGET_PREFIX}"
echo

echo "Login to docker..."
if [ -z "$IMAGE_TARGET_PREFIX" ]; then
    CMD_LOGIN="docker login"
else
    CMD_LOGIN="docker login --username $IMAGE_TARGET_PREFIX"
fi
echo $CMD_LOGIN
eval $CMD_LOGIN
RC=$?
if [ $RC -ne 0 ]; then
    echo "Failed with return code $RC"
    exit 2
fi
echo

echo "Share the image..."
CMD_PUSH="docker push ${TRG_IMAGE_NAME}:${TAG_NAME}"
echo $CMD_PUSH
eval $CMD_PUSH
RC=$?
if [ $RC -ne 0 ]; then
    echo "Failed with return code $RC"
    echo "TIP: The target repo must already exist before you can push images to it."
    echo "     Login to your '${IMAGE_TARGET_PREFIX}' account on docker.com and check."
    echo "     Create a repo for '${IMAGE_NAME}' if not already found there."
    if [ $WARNCOUNT -ne 0 ]; then
        echo "ALSO ---- Check above for the $WARNCOUNT warning messages!!!"
    fi
    exit 2
fi
echo

echo "Finished $0 v$VERSIONINFO"
echo

