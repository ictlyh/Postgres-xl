#!/usr/bin/env bash

if [ $# -ne 1 ]; then
	echo "Usage: $0 start|stop|restart"
	exit 1
fi

command=$1

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
# make sure PATH and LD_LIBRARY_PATH take effect
source ~/.bashrc

case "$command" in
	start )
		# 不能用 -l 指定日志文件，否则启动失败
		# 另外要保证 gtm 可执行文件在 PATH 环境变量中
		./bin/gtm_ctl -D /data1/gtm -Z gtm start
		for i in $(seq $dn_count); do
			./bin/pg_ctl -D /data$i/node$i -Z datanode -l /data$i/node$i/logfile start
		done
		for i in $(seq $co_count); do
			./bin/pg_ctl -D /data$i/coord$i -Z coordinator -l /data$i/coord$i/logfile start
		done
		;;
	stop )
		for i in $(seq $co_count); do
			./bin/pg_ctl -D /data$i/coord$i -Z coordinator stop
		done
		for i in $(seq $dn_count); do
			./bin/pg_ctl -D /data$i/node$i -Z datanode stop
		done
		./bin/gtm_ctl -D /data1/gtm -Z gtm stop
		;;
	restart )
		# 不能用 -l 指定日志文件，否则启动失败
		# 另外要保证 gtm 可执行文件在 PATH 环境变量中
		./bin/gtm_ctl -D /data1/gtm -Z gtm restart
		for i in $(seq $dn_count); do
			./bin/pg_ctl -D /data$i/node$i -Z datanode -l /data$i/node$i/logfile restart
		done
		for i in $(seq $co_count); do
			./bin/pg_ctl -D /data$i/coord$i -Z coordinator -l /data$i/coord$i/logfile restart
		done
		;;
	* )
		echo "Usage: $0 start|stop|restart"
		exit 1
		;;
esac

popd
