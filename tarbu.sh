#!/bin/bash

# tarbu
# by Remi Plourde
# <http://github.com/remino/tarbu>

tarbu_main() {
  [ $# -lt 1 ] && tarbu_usage

  TARBU_ACTION=$1
  FROM=""
  TO=""
  shift
  case $TARBU_ACTION in
    backup) tarbu_backup $@;;
    copy) tarbu_copy $@;;
    expire) tarbu_expire $@;;
    tarball) tarbu_tarball $@;;
    *) tarbu_usage;;
  esac
}

tarbu_backup() {
  [ $# -lt 2 ] && tarbu_usage
  TIME="$( date +%Y%m%d-%H%M%S )"
  DIRNAME="$( basename "$1" )"
  [ "$3" != "" ] && DIRNAME=$3
  FROM="$1"
  BACKUPDIR="$2"
  TO="$BACKUPDIR/$DIRNAME"
  TARBALL="$DIRNAME-$TIME.tar.bz2"
  tarbu_copy "$FROM" "$TO"
  cd "$BACKUPDIR"
  tarbu_tarball "$DIRNAME" "$TARBALL"
}

tarbu_copy() {
  [ $# -lt 2 ] && tarbu_usage
  FROM="$1/"
  TO="$2/"
  [ ! -d "$FROM" ] && tarbu_fail "Directory $FROM does not exist."
  [ ! -d "$TO" ] && \
    ( mkdir -p "$TO" || tarbu_fail "Directory $TO couldn't be created." )
  tarbu_log "Copying $FROM to $TO..."
  rsync -avz "$FROM" "$TO"
}

tarbu_expire() {
  [ $# -lt 1 ] && tarbu_usage
}

tarbu_fail() {
  echo `basename $0`: $@
  exit 1
}

tarbu_log() {
  echo $( basename $0 ) $( date +"%Y-%m-%d %H:%M:%S %Z" ): $@
}

tarbu_tarball() {
  [ $# -lt 2 ] && tarbu_usage
  FROM="$1"
  TO="$2"
  [ ! -d "$FROM" ] && tarbu_fail "Directory $FROM does not exist."
  tarbu_log "Rolling $FROM in $TO..."
  tar -jcvf "$TO" "$FROM"
}

tarbu_usage() {
  echo "Usage: `basename $0` action args..."
  echo ""
  echo "Actions:"
  echo "  backup what into"
  echo "    Backup 'what' inside 'into' directory, with dir copy and tarball."
  echo "  copy from to"
  echo "    Copy 'from' directory structure and its files to 'to'."
  echo "  expire backupdir"
  echo "    Delete all tarballs older than 5 days in 'backupdir'."
  echo "  tarball dir file.tar.bz2"
  echo "    Tarball directory into file.tar.bz2."
  exit 1
}

tarbu_main $@
