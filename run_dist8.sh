#!/bin/bash

# launch.py 스크립트를 사용하여 분산 환경에서 작업을 시작하고 관리하는 스크립트
# 주로 머신 러닝 작업을 여러 노드에서 병렬로 실행하는 데 사용됨
# 이 스크립트는 몇 가지 환경 변수를 설정하고, launch.py를 실행하며, 실행 중인 작업을 중지할 수 있도록 신호 처리를 설정함
PYG_WORKSPACE=$PWD # 현재 작업 디렉토리 지정
USER="gnn" # SSH 접속 시 사용할 사용자 이름 설정
PY_EXEC="python3" # Python 실행 파일 지정
EXEC_SCRIPT="${PYG_WORKSPACE}/node_ogb_cpu.py" # 실행할 Python 스크립트 경로 설정
CMD="cd ${PYG_WORKSPACE}; ${PY_EXEC} ${EXEC_SCRIPT}" # 작업 디렉토리로 이동한 후, Python 스크립트를 실행

# 분산 환경 설정
NUM_NODES=8 # 사용할 노드 수

DATASET=ogbn-products # 사용할 데이터셋

DATASET_ROOT_DIR="./data_8/partitions/${DATASET}/${NUM_NODES}-parts" # 데이터셋의 루트 디렉토리 설정
# Number of epochs:
NUM_EPOCHS=10

# The batch size:
BATCH_SIZE=1024

# Fanout per layer:
NUM_NEIGHBORS="5,5,5"

# Number of workers for sampling:
NUM_WORKERS=2
CONCURRENCY=4

# DDP Port
#DDP_PORT=11111

# IP configuration path:
IP_CONFIG=${PYG_WORKSPACE}/ip_config8.yaml

# stdout stored in `/logdir/logname.out`.
python3 launch.py --workspace ${PYG_WORKSPACE} --ip_config ${IP_CONFIG} --ssh_username ${USER} --num_nodes ${NUM_NODES} --num_neighbors ${NUM_NEIGHBORS} --dataset_root_dir ${DATASET_ROOT_DIR} --dataset ${DATASET}  --num_epochs ${NUM_EPOCHS} --batch_size ${BATCH_SIZE} --num_workers ${NUM_WORKERS} --concurrency ${CONCURRENCY} "${CMD}" & pid=$!
# 작업 시작 알림 및 신호 처리
echo "started test_launch.py: ${pid}"
trap "kill -2 $pid" SIGINT # SIGINT (Ctrl+C) 신호가 발생했을 때 실행 중인 프로세스를 종료하도록 설정
wait $pid # launch.py 실행이 완료될 때까지 대기
set +x # 스크립트 실행 중지