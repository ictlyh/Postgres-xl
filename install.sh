#!/usr/bin/env bash

ROOT=$(cd $(dirname $0); pwd)

# source directory of postgres-xl
PGXL_SRC=/home/luoyuanhao/Workspace/postgresxl
# directory where postgres-xl is install to
PGXL_HOME=/home/luoyuanhao/Softwares/pgxl

if [ ! -d ${PGXL_SRC} ]; then
	git clone git://git.postgresql.org/git/postgres-xl.git ${PGXL_SRC}
fi

pushd ${PGXL_SRC}
rm -rf ${PGXL_HOME}

./configure --prefix=${PGXL_HOME}
gmake && gmake install

echo "
export PATH=${PGXL_HOME}/bin:\${PATH}
" >> ~/.bashrc
source ~/.bashrc

popd