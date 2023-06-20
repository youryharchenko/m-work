#!/bin/bash

export MYSQL_PWD=$KB_PWD


mysql -v -h$KB_HOST -u$KB_USER -D$KB_DB < view/create_all_c.sql
mysql -v -h$KB_HOST -u$KB_USER -D$KB_DB < view/create_all_o.sql
mysql -v -h$KB_HOST -u$KB_USER -D$KB_DB < view/create_all_co.sql

mysql -v -h$KB_HOST -u$KB_USER -D$KB_DB < view/create_all_r.sql
mysql -v -h$KB_HOST -u$KB_USER -D$KB_DB < view/create_all_rc.sql
mysql -v -h$KB_HOST -u$KB_USER -D$KB_DB < view/create_all_rco.sql

mysql -v -h$KB_HOST -u$KB_USER -D$KB_DB < view/create_all_a.sql
mysql -v -h$KB_HOST -u$KB_USER -D$KB_DB < view/create_all_ac.sql
mysql -v -h$KB_HOST -u$KB_USER -D$KB_DB < view/create_all_aco.sql
mysql -v -h$KB_HOST -u$KB_USER -D$KB_DB < view/create_all_ar.sql
mysql -v -h$KB_HOST -u$KB_USER -D$KB_DB < view/create_all_arc.sql
mysql -v -h$KB_HOST -u$KB_USER -D$KB_DB < view/create_all_arco.sql

