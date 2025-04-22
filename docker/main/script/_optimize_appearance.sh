#!/bin/bash

echo "------------------START: optimize_appearance"
echo "case_name: $1"

exp_name="init=hybrid_iso=True_ldepth=0.001_lnormal=0.0_laniso_0.0_lseg=1.0"

../exec.sh "python PhysTwin/gs_train.py \
    -s mount/ws/data/gaussian_data/$1 \
    -m mount/ws/gaussian_output/$1/${exp_name} \
    --iterations 10000 \
    --lambda_depth 0.001 \
    --lambda_normal 0.0 \
    --lambda_anisotropic 0.0 \
    --lambda_seg 1.0 \
    --use_masks \
    --isotropic \
    --gs_init_opt 'hybrid'"

if [ $? -ne 0 ]; then
    echo "optimize_appearanceに失敗しました"
    exit 1
fi

echo "------------------END: optimize_appearance"