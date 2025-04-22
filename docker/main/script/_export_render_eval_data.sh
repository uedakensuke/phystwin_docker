#!/bin/bash

echo "------------------START: export_render_eval_data"
echo "case_name: $1"

./vglrun.sh "python PhysTwin/export_render_eval_data.py \
    --base_path mount/ws/data/different_types \
    --eval_path mount/ws/export \
    --case_name $1"

if [ $? -ne 0 ]; then
    echo "export_render_eval_dataに失敗しました"
    exit 1
fi

echo "------------------END: export_render_eval_data"
