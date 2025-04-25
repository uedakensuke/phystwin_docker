#!/bin/bash

echo "------------------START: visualize_force"
echo "case_name: $1"

./vglrun.sh "python PhysTwin/visualize_force.py \
    --raw_path mount/ws/raw \
    --base_path mount/ws/data/different_types \
    --physics_sparse_path mount/ws/experiments_optimization \
    --physics_dense_path mount/ws/experiments \
    --gaussian_path mount/ws/gaussian_output \
    --inference_path mount/ws/render \
    --case_name $1"

if [ $? -ne 0 ]; then
    echo "visualize_forceに失敗しました"
    exit 1
fi

echo "------------------END: visualize_force"
