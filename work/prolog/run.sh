#!/bin/bash

DIR=$HOME/Project/m-work/work/prolog
TARGET=$DIR/target

echo $TARGET

java \
    -cp $TARGET/bg-jobs/sbt_292a995f/target/74933a35/8874565d/scala3-library_3-3.2.2.jar \
    -Duser.dir=$DIR \
    -jar $TARGET/scala-3.2.2/prolog_3-0.1-SNAPSHOT.jar \ 
    prolog.Main

