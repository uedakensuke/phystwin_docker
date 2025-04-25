#!/bin/bash

echo "------------------START: evaluate"
echo "case_name: $1"

../exec.sh "python PhysTwin/evaluate_chamfer.py \
    --base_path mount/ws/data/different_types \
    --inference_path mount/ws/render \
    --eval_path mount/ws/export \
    --case_name $1"

if [ $? -ne 0 ]; then
    echo "evaluate_chamferに失敗しました"
fi

# comment out. 評価に必要となるgt_track_3d.pklを生成するコードがない為
# ../exec.sh "python PhysTwin/evaluate_track.py \
#     --base_path mount/ws/data/different_types \
#     --inference_path mount/ws/render \
#     --eval_path mount/ws/export \
#     --case_name $1"

# if [ $? -ne 0 ]; then
#     echo "evaluate_trackに失敗しました"
# fi

../exec.sh "python PhysTwin/gaussian_splatting/evaluate_render.py \
    --human_mask_path mount/ws/data/different_types_human_mask \
    --inference_path mount/ws/render \
    --eval_path mount/ws/export \
    --case_name $1"

if [ $? -ne 0 ]; then
    echo "evaluate_renderに失敗しました"
fi

echo "------------------END: evaluate"
