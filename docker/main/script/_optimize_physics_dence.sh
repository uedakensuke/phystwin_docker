#!/bin/bash
echo "------------------START: optimize_physics_dense"
echo "case_name: $1"

./vglrun.sh "python PhysTwin/train_warp.py \
    --raw_path mount/ws/raw \
    --base_path mount/ws/data/different_types \
    --physics_sparse_path mount/ws/experiments_optimization \
    --physics_dense_path mount/ws/experiments \
    --case_name $1"

if [ $? -ne 0 ]; then
    echo "optimize_physics_denseに失敗しました"
    exit 1
fi

echo "------------------END: optimize_physics_dense"
