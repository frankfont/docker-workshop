#!/bin/bash
VERSIONINFO="20180630.1"
echo "Starting $0 v$VERSIONINFO"
echo "DOCKERFILE_MACHINEBUILD_VERSION=$DOCKERFILE_MACHINEBUILD_VERSION"
echo

PARAM1=$1
if [ -z "$PARAM1" ]; then
    echo "... NO PARAMS"
else
    echo "... PARAM1=$PARAM1"
fi

if [ ! "TERMINATES" = "$PARAM1" ]; then
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "Starting tail at $TIMESTAMP forever to prevent machine termination in $0 v$VERSIONINFO (Machine v$DOCKERFILE_MACHINEBUILD_VERSION)"
    tail -f /dev/null
fi
echo "Completed $0"
