#!/bin/bash

source ${BASH_SOURCE%/*}/settings.sh

ping ${OKD_MASTER_NODE_1_HOSTNAME} -c 1
ping ${OKD_WORKER_NODE_1_HOSTNAME} -c 1
ping ${OKD_WORKER_NODE_2_HOSTNAME} -c 1