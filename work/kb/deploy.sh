#!/bin/bash

source $(dirname $0)/.kb

echo $SITE_USER
echo $SITE_HOST
echo $SITE_DIR

read -p "Continue (y/n)?[y]" CONT
if [ "$CONT" = "n" ]; then
    exit 0
fi


USER=$SITE_USER
HOST=$SITE_HOST
DIR=$SITE_DIR
PORT=22
MOUNT=./deploy
TARGET=$MOUNT/www

go build -o cgi/kb.cgi ./cgi

docker-machine mount $HOST:$DIR $MOUNT

sleep 5s

cp -v -u ./cgi/kb.cgi $TARGET/

cat $MOUNT/cgi.log > cgi.log

sleep 5s

docker-machine mount -u $HOST:$DIR $MOUNT

ls -al $MOUNT

