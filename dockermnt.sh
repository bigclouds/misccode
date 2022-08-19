#!/bin/sh
# docker-enter
if [ -e $(dirname "$0")/nsenter ]; then
  # with boot2docker, nsenter is not in the PATH but it is in the same folder
  NSENTER=$(dirname "$0")/nsenter
else
  NSENTER=nsenter
fi

if [ -z "$1" ]; then
  echo "Usage: `basename "$0"` CONTAINER [COMMAND [ARG]...]"
  echo ""
  echo "Enters the Docker CONTAINER and executes the specified COMMAND."
  echo "If COMMAND is not specified, runs an interactive shell in CONTAINER."
else
  PID=$(docker inspect --format "{{.State.Pid}}" "$1")
  if [ -z "$PID" ]; then
    exit 1
  fi
  shift

  OPTS="--target $PID --mount --uts --ipc --net --pid --"

  if [ -z "$1" ]; then
    # No command given.
    # Use su to clear all host environment variables except for TERM,
    # initialize the environment variables HOME, SHELL, USER, LOGNAME, PATH,
    # and start a login shell.
#"$NSENTER" $OPTS su - root
"$NSENTER" $OPTS /bin/su - root
  else
    # Use env to clear all host environment variables.
    "$NSENTER" $OPTS env --ignore-environment -- "$@"
  fi
fi

##-------------------------------
#!/bin/bash
set -ex

useage(){
    echo "useage:"
    echo "  dockermnt.sh CONTAINER HOSTPATH CONTPATH"
}

if [ $# -ne 3 ];then
    useage
    exit
fi

CONTAINER=$1
HOSTPATH=$2
CONTPATH=$3

REALPATH=$(readlink --canonicalize "$HOSTPATH")
FILESYS=$(df -P "$REALPATH" | tail -n 1 | awk '{print $6}')

while read -r DEV MOUNT JUNK
do [ "$MOUNT" = "$FILESYS" ] && break
done </proc/mounts
[ "$MOUNT" = "$FILESYS" ] # Sanity check!

while read -r A B C SUBROOT MOUNT JUNK
do [ "$MOUNT" = "$FILESYS" ] && break
done < /proc/self/mountinfo 
[ "$MOUNT" = "$FILESYS" ] # Moar sanity check!

SUBPATH=$(echo "$REALPATH" | sed s,^$FILESYS,,)
DEVDEC=$(printf "%d %d" $(stat --format "0x%t 0x%T" $DEV))

docker-enter "$CONTAINER" sh -c \
	     "[ -b $DEV ] || mknod --mode 0600 $DEV b $DEVDEC"
docker-enter "$CONTAINER" mkdir /tmpmnt
docker-enter "$CONTAINER" mount "$DEV" /tmpmnt
docker-enter "$CONTAINER" mkdir -p "$CONTPATH"
docker-enter "$CONTAINER" mount -o bind "/tmpmnt/$SUBROOT/$SUBPATH" "$CONTPATH"
docker-enter "$CONTAINER" umount /tmpmnt
docker-enter "$CONTAINER" rmdir /tmpmnt
