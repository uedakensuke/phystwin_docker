#!/bin/bash

echo "------------------START: visualize_render_results"
echo "case_name: $1"

../exec.sh "python PhysTwin/visualize_render_results.py \
    --base_path mount/ws/data/different_types \
    --human_mask_path mount/ws/data/different_types_human_mask \
    --inference_path mount/ws/render \
    --eval_path mount/ws/export \
    --case_name $1"

if [ $? -ne 0 ]; then
    echo "visualize_render_resultsに失敗しました"
    exit 1
fi

echo "------------------END: visualize_render_results"
