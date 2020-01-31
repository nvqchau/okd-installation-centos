#!/bin/bash

source settings.sh

ping ${OKD_MASTER_NODE_1_HOSTNAME} -c 1
ping ${OKD_INFRA_NODE_1_HOSTNAME} -c 1
ping ${OKD_WORKER_NODE_1_HOSTNAME} -c 1
ping ${OKD_WORKER_NODE_2_HOSTNAME} -c 1
ping ${OKD_WORKER_NODE_3_HOSTNAME} -c 1