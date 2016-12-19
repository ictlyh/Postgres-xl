#!/usr/bin/env bash

if [ $# -ne 1 ]; then
	echo "Usage: $0 start|stop|restart"
	exit 1
fi

command=$1

PGXL_HOME=/home/luoyuanhao/Softwares/pgxl

pushd ${PGXL_HOME}

case "$command" in
	start )
		# 不能用 -l 指定日志文件，否则启动失败
		# 另外要保证 gtm 可执行文件在 PATH 环境变量中
		./bin/gtm_ctl -D ./data/gtm -Z gtm start
		./bin/pg_ctl -D ./data/node1 -Z datanode -l ./data/node1/logfile start
		./bin/pg_ctl -D ./data/node2 -Z datanode -l ./data/node2/logfile start
		./bin/pg_ctl -D ./data/coord1 -Z coordinator -l ./data/coord1/logfile start
		./bin/pg_ctl -D ./data/coord2 -Z coordinator -l ./data/coord2/logfile start
		;;
	stop )
		./bin/pg_ctl -D ./data/coord1 -Z coordinator stop
		./bin/pg_ctl -D ./data/coord2 -Z coordinator stop
		./bin/pg_ctl -D ./data/node1 -Z datanode stop
		./bin/pg_ctl -D ./data/node2 -Z datanode stop
		./bin/gtm_ctl -D ./data/gtm -Z gtm stop
		;;
	restart )
		# 不能用 -l 指定日志文件，否则启动失败
		# 另外要保证 gtm 可执行文件在 PATH 环境变量中
		./bin/gtm_ctl -D ./data/gtm -Z gtm restart
		./bin/pg_ctl -D ./data/node1 -Z datanode -l ./data/node1/logfile restart
		./bin/pg_ctl -D ./data/node2 -Z datanode -l ./data/node2/logfile restart
		./bin/pg_ctl -D ./data/coord1 -Z coordinator -l ./data/coord1/logfile restart
		./bin/pg_ctl -D ./data/coord2 -Z coordinator -l ./data/coord2/logfile restart
		;;
	* )
		echo "Usage: $0 start|stop|restart"
		exit 1
		;;
esac

popd
