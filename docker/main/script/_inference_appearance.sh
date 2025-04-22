#!/bin/bash

echo "------------------START: inference_appearance"
echo "case_name: $1"

exp_name="init=hybrid_iso=True_ldepth=0.001_lnormal=0.0_laniso_0.0_lseg=1.0"

../exec.sh "python PhysTwin/gs_render.py \
    -s mount/ws/data/gaussian_data/$1 \
    -m mount/ws/gaussian_output/$1/${exp_name} \
    --out_dir mount/ws/render/$1/appearance"

if [ $? -ne 0 ]; then
    echo "inference_appearanceに失敗しました"
    exit 1
fi

../exec.sh "python PhysTwin/gaussian_splatting/img2video.py \
    --image_folder mount/ws/render/$1/appearance/test/ours_10000/renders \
    --video_path mount/ws/render/$1/appearance/test/test.mp4"

echo "------------------END: inference_appearance"
