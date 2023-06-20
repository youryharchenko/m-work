#!/bin/bash

export MYSQL_PWD=$KB_PWD

mysql -v -h$KB_HOST -u$KB_USER -D$KB_DB < sql/create_v.sql
#mysql -v -h$KB_HOST -u$KB_USER -D$KB_DB -e "DESCRIBE v;"

mysql -v -h$KB_HOST -u$KB_USER -D$KB_DB < sql/create_c.sql
mysql -v -h$KB_HOST -u$KB_USER -D$KB_DB < sql/create_o.sql
mysql -v -h$KB_HOST -u$KB_USER -D$KB_DB < sql/create_co.sql

mysql -v -h$KB_HOST -u$KB_USER -D$KB_DB < sql/create_r.sql
mysql -v -h$KB_HOST -u$KB_USER -D$KB_DB < sql/create_rc.sql
mysql -v -h$KB_HOST -u$KB_USER -D$KB_DB < sql/create_rco.sql

mysql -v -h$KB_HOST -u$KB_USER -D$KB_DB < sql/create_a.sql
mysql -v -h$KB_HOST -u$KB_USER -D$KB_DB < sql/create_ac.sql
mysql -v -h$KB_HOST -u$KB_USER -D$KB_DB < sql/create_aco.sql
mysql -v -h$KB_HOST -u$KB_USER -D$KB_DB < sql/create_ar.sql
mysql -v -h$KB_HOST -u$KB_USER -D$KB_DB < sql/create_arc.sql
mysql -v -h$KB_HOST -u$KB_USER -D$KB_DB < sql/create_arco.sql

