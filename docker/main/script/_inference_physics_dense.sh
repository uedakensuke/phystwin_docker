#!/bin/bash

echo "------------------START: inference_physics_dense"
echo "case_name: $1"

./vglrun.sh "python PhysTwin/inference_warp.py \
    --base_path mount/ws/data/different_types \
    --physics_sparse_path mount/ws/experiments_optimization \
    --physics_dense_path mount/ws/experiments \
    --inference_path mount/ws/render \
    --case_name $1"

if [ $? -ne 0 ]; then
    echo "inference_physics_denseに失敗しました"
    exit 1
fi

echo "------------------END: inference_physics_dense"
