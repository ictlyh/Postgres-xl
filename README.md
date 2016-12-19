### Scripts for installing, initiating and controlling postgres-xl cluster

[![Build Status](https://travis-ci.org/ictlyh/Postgres-xl.svg?branch=master)](https://travis-ci.org/ictlyh/Postgres-xl)


These script are used for:  
1. installing postgres-xl  
2. building a postgres-xl cluster with two datanodes, two coordinators and one gtm  
3. controlling the postgres-xl cluster  

#### Install
1. edit **PGXL\_SRC** and **PGXL\_HOME** in install.sh to the directories as you like.  
2. run **sh install.sh**  
If any error occurs, fix it and re-install.

#### Initialize
1. edit configuration parameters(such as nodename, nodeport) in **init.sh** as you like.  
2. run **sh init.sh**  

#### Control
run **sh ctl.sh [start/stop/restart]** to start/stop/restart the postgres-xl cluster.
