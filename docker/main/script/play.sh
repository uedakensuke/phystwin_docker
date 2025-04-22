#!/bin/bash
if [ $# -eq 1 ];then
    extra=""
elif [ $# -eq 2 ];then
    extra="--n_ctrl_parts $2"
else
    echo USAGE: play.sh case_name [n_ctrl_parts]
    exit 1
fi

../exec.sh "python PhysTwin/interactive_playground.py \
    --base_path mount/ws/data/different_types \
    --physics_sparse_path mount/ws/experiments_optimization \
    --physics_dense_path mount/ws/experiments \
    --gaussian_path mount/ws/gaussian_output \
    --bg_img_path mount/ws/data/bg.png \
    --inference_path mount/ws/render \
    --case_name $1 \
    $extra"
