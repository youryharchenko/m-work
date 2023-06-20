#!/bin/bash

export MYSQL_PWD=$KB_PWD

mysql -v -h$KB_HOST -u$KB_USER -D$KB_DB < utils/truncate.sql

