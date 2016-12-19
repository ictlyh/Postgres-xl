#!/usr/bin/env bash

ROOT=$(cd $(dirname $0); pwd)

# source directory of postgres-xl
PGXL_SRC=${ROOT}/postgres-xl
# directory where postgres-xl is install to
PGXL_HOME=${ROOT}/pgxl
export PATH=${PGXL_HOME}/bin:${PATH}

if [ ! -d ${PGXL_SRC} ]; then
	git clone git://git.postgresql.org/git/postgres-xl.git ${PGXL_SRC}
fi

#pushd ${PGXL_SRC}
cd ${PGXL_SRC}
rm -rf ${PGXL_HOME}

CFLAGS='-O0 -g -ggdb' ./configure --prefix=${PGXL_HOME}
make -j`nproc` && make install

echo "
export PATH=${PGXL_HOME}/bin:\${PATH}
" >> ~/.bashrc
#source ~/.bashrc

#popd
cd -
