#!/bin/bash

echo "------------------START: inference_dynamic"
echo "case_name: $1"

exp_name='init=hybrid_iso=True_ldepth=0.001_lnormal=0.0_laniso_0.0_lseg=1.0'

../exec.sh "python PhysTwin/gs_render_dynamics.py \
    -s mount/ws/data/gaussian_data/$1 \
    -m mount/ws/gaussian_output/$1/${exp_name} \
    --inference_path mount/ws/render \
    --white_background"

if [ $? -ne 0 ]; then
    echo "inference_dynamicに失敗しました"
    exit 1
fi

views=("0" "1" "2")
for view_name in "${views[@]}"; do
    # Convert images to video
    ../exec.sh "python PhysTwin/gaussian_splatting/img2video.py \
        --image_folder mount/ws/render/$1/dynamic/${view_name} \
        --video_path mount/ws/render/$1/dynamic/${view_name}.mp4"
done

echo "------------------END: inference_dynamic"
