#!/bin/bash

export MYSQL_PWD=$KB_PWD

mysql -v -h$KB_HOST -u$KB_USER -D$KB_DB < sp/create_make_v.sql
#mysql -v -h$KB_HOST -u$KB_USER -D$KB_DB -e "DESCRIBE v;"

mysql -v -h$KB_HOST -u$KB_USER -D$KB_DB < sp/create_make_c.sql
mysql -v -h$KB_HOST -u$KB_USER -D$KB_DB < sp/create_make_o.sql
mysql -v -h$KB_HOST -u$KB_USER -D$KB_DB < sp/create_make_co.sql

mysql -v -h$KB_HOST -u$KB_USER -D$KB_DB < sp/create_make_r.sql
mysql -v -h$KB_HOST -u$KB_USER -D$KB_DB < sp/create_make_rc.sql
mysql -v -h$KB_HOST -u$KB_USER -D$KB_DB < sp/create_make_rco.sql

mysql -v -h$KB_HOST -u$KB_USER -D$KB_DB < sp/create_make_a.sql
mysql -v -h$KB_HOST -u$KB_USER -D$KB_DB < sp/create_make_ac.sql
mysql -v -h$KB_HOST -u$KB_USER -D$KB_DB < sp/create_make_aco.sql
mysql -v -h$KB_HOST -u$KB_USER -D$KB_DB < sp/create_make_ar.sql
mysql -v -h$KB_HOST -u$KB_USER -D$KB_DB < sp/create_make_arc.sql
mysql -v -h$KB_HOST -u$KB_USER -D$KB_DB < sp/create_make_arco.sql

