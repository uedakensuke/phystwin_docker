#!/bin/bash
echo "------------------START: optimize_physics_sparse"
echo "case_name: $1"

./vglrun.sh "python PhysTwin/optimize_cma.py \
    --base_path mount/ws/data/different_types \
    --physics_sparse_path mount/ws/experiments_optimization \
    --case_name $1"

if [ $? -ne 0 ]; then
    echo "optimize_physics_sparseに失敗しました"
    exit 1
fi

echo "------------------END: optimize_physics_sparse"