#!/usr/bin/env bash

ROOT=$(cd $(dirname $0); pwd)

# source directory of postgres-xl
PGXL_SRC=${ROOT}/postgres-xl
# directory where postgres-xl is install to
PGXL_HOME=${HOME}/pgxl

master=nobida208
standby=nobida209

if [ ! -d ${PGXL_SRC} ]; then
	git clone git://git.postgresql.org/git/postgres-xl.git ${PGXL_SRC}
fi

pushd ${PGXL_SRC}
rm -rf ${PGXL_HOME}

./configure --prefix=${PGXL_HOME}
gmake -j`nproc` && gmake install

echo "
export LD_LIBRARY_PATH=${PGXL_HOME}/lib:\${LD_LIBRARY_PATH}
export PATH=${PGXL_HOME}/bin:\${PATH}
" >> ~/.bashrc

# synchronize postgres-xl to standby
ssh ${standby} "rm -rf ${PGXL_HOME}"
ssh ${standby} "mkdir -p ${PGXL_HOME}"
rsync -rL ${PGXL_HOME}/ ${standby}:${PGXL_HOME}/
ssh ${stdndby} "echo 'export LD_LIBRARY_PATH=${PGXL_HOME}/lib:\${LD_LIBRARY_PATH}' >>~/.bashrc"
ssh ${standby} "echo 'export PATH=${PGXL_HOME}/bin:\${PATH}' >>~/.bashrc"

popd
