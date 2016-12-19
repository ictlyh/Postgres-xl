#!/usr/bin/env bash

ROOT=$(cd $(dirname $0); pwd)
PGXL_HOME=${ROOT}/pgxl
export PATH=${PGXL_HOME}/bin:${PATH}

#pushd ${PGXL_HOME}
cd ${PGXL_HOME}

# cat << EOF
# 
# ********************************************************************************
# WARNING: This will remove ${PGXL_HOME}/data. Are you sure?[yn]
# ********************************************************************************
# 
# EOF
# agreed=
# while [ -z "${agreed}" ] ; do
#     read reply leftover
#     case $reply in
#         [yY] | [yY][eE][sS])
#             agreed=1
#             ;;
#         [nN] | [nN][oO])
#             cat << EOF
# 
# ********************************************************************************
#                                  Exiting
# ********************************************************************************
# 
# EOF
#             exit 1
#             ;;
#     esac
# done

sh ${ROOT}/ctl.sh stop
sleep 2

rm -rf ./data
mkdir ./data

./bin/initdb -D ./data/node1 --nodename node1
./bin/initdb -D ./data/node2 --nodename node2

echo "
listen_addresses = '*'
port = 25431
gtm_host = 'localhost'
gtm_port = 6666
pooler_port = 35431
" >> ./data/node1/postgresql.conf

echo "
host all all 0.0.0.0/0 trust
" >> ./data/node1/pg_hba.conf

echo "
listen_addresses = '*'
port = 25432
gtm_host = 'localhost'
gtm_port = 6666
pooler_port = 35432
" >> ./data/node2/postgresql.conf

echo "
host all all 0.0.0.0/0 trust
" >> ./data/node2/pg_hba.conf

./bin/initgtm -Z gtm -D ./data/gtm

./bin/initdb -D ./data/coord1 --nodename coord1
./bin/initdb -D ./data/coord2 --nodename coord2

echo "
listen_addresses = '*'
port = 2921
gtm_host = 'localhost'
gtm_port = 6666
pooler_port = 6667
" >> ./data/coord1/postgresql.conf

echo "
host all all 0.0.0.0/0 trust
" >> ./data/coord1/pg_hba.conf

echo "
listen_addresses = '*'
port = 2922
gtm_host = 'localhost'
gtm_port = 6666
pooler_port = 6668
" >> ./data/coord2/postgresql.conf

echo "
host all all 0.0.0.0/0 trust
" >> ./data/coord2/pg_hba.conf

sh ${ROOT}/ctl.sh start
sleep 2

./bin/psql -d postgres -p 2921 -f ${ROOT}/register.sql
./bin/psql -d postgres -p 2922 -f ${ROOT}/register.sql
./bin/psql -d postgres -p 25431 -f ${ROOT}/register.sql
./bin/psql -d postgres -p 25432 -f ${ROOT}/register.sql

./bin/psql -d postgres -p 2921 -c 'create database test'

#popd
cd -
${PGXL_HOME}/bin/psql -p 2921Utils.svg -d test -c 'create table tb1(id int, name text)'
${PGXL_HOME}/bin/psql -p 2922 -d test -c "insert into tb1 values(1,'haha'),(2,'hehe')"
${PGXL_HOME}/bin/psql -p 2921 -d test -c 'select * from tb1'
