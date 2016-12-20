#!/usr/bin/env bash

ROOT=$(cd $(dirname $0); pwd)
PGXL_HOME=${HOME}/pgxl

master=nobida208
standby=nobida209
gtm_port=6666
dn_base_port=25430
dn_base_pooler_port=35430
dn_count=2
co_base_port=2920
co_count=2

pushd ${PGXL_HOME}

sh ${ROOT}/ctl.sh stop 
sleep 2

for i in $(seq $dn_count); do
	rm -rf /data$i/node$i
	./bin/initdb -D /data$i/node$i --nodename node$i
	echo "
listen_addresses = '*'
port = $(($dn_base_port + $i))
gtm_host = '$master'
gtm_port = $gtm_port
pooler_port = $(($dn_base_pooler_port + $i))
" >> /data$i/node$i/postgresql.conf
	echo "
host all all 0.0.0.0/0 trust
" >> /data$i/node$i/pg_hba.conf
done

./bin/initgtm -Z gtm -D /data1/gtm

for i in $(seq $co_count); do
	rm -rf /data$i/coord$i
	./bin/initdb -D /data$i/coord$i --nodename coord$i
	echo "
listen_addresses = '*'
port = $(($co_base_port + $i))
gtm_host = '$master'
gtm_port = $gtm_port
pooler_port = $(($gtm_port + $i))
" >> /data$i/coord$i/postgresql.conf
	echo "
host all all 0.0.0.0/0 trust
" >> /data$i/coord$i/pg_hba.conf
done

sh ${ROOT}/ctl.sh start
sleep 2

# generate register.sql
rm -rf ${ROOT}/register.sql
for i in $(seq $dn_count); do
	echo "
drop node node$i;
drop node group gp$i;
create node node$i with(TYPE='datanode', HOST='$master', PORT=$(($dn_base_port + $i)));
alter node node$i with(TYPE='datanode', HOST='$master', PORT=$(($dn_base_port + $i)));
create node group gp$i with(node$i);
" >>${ROOT}/register.sql
done
for i in $(seq $co_count); do
	echo "
drop node coord$i;
create node coord$i with(TYPE='coordinator',HOST='$master',PORT=$(($co_base_port + $i)));
alter node coord$i with(TYPE='coordinator',HOST='$master',PORT=$(($co_base_port + $i)));
" >>${ROOT}/register.sql
done
echo "
select pgxc_pool_reload();
select * from pgxc_node;
" >>${ROOT}/register.sql

# run register query on data nodes and coordinators
for i in $(seq $dn_count); do
	./bin/psql -d postgres -p $(($dn_base_port + $i)) -f ${ROOT}/register.sql
done
for i in $(seq $co_count); do
	./bin/psql -d postgres -p $(($co_base_port + $i)) -f ${ROOT}/register.sql
done

popd
