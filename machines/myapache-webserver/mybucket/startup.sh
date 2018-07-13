#!/bin/bash
VERSIONINFO="20180630.2"
echo "Starting $0 v$VERSIONINFO"
echo "DOCKERFILE_MACHINEBUILD_VERSION=$DOCKERFILE_MACHINEBUILD_VERSION"
echo
WHOAMI=$(whoami)
if [ ! "root" = "$WHOAMI" ]; then
    echo "WARNING: You may need to run this script as root or use sudo command."
fi
PARAM1=$1
echo "... USER  = $WHOAMI"
if [ -z "$PARAM1" ]; then
    echo "... NO PARAMS"
else
    echo "... PARAM1= $PARAM1"
fi
echo

DELAY=6
echo "Will try to start apache2 in $DELAY seconds ..."
sleep $DELAY
service apache2 start
sleep $DELAY
ps -aux
echo
FOUND=$(ps -aux | grep apache2)
if [ ! -z "$FOUND" ]; then
    echo "Done starting apache2!"
else
    echo
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "FAILED starting apache2!"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo
fi
if [ ! "TERMINATES" = "$PARAM1" ]; then
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "Starting tail at $TIMESTAMP forever to prevent machine termination in $0 v$VERSIONINFO (Machine v$DOCKERFILE_MACHINEBUILD_VERSION)"
    tail -f /dev/null
fi
echo "Completed $0"
