#!/bin/bash
echo "------------------START: export_gaussian_data"
echo "case_name: $1"

./vglrun.sh "python PhysTwin/export_gaussian_data.py \
    --raw_path mount/ws/raw \
    --base_path mount/ws/data/different_types \
    --case_name $1"

if [ $? -ne 0 ]; then
    echo "export_gaussian_dataに失敗しました"
    exit 1
fi

echo "------------------END: export_gaussian_data"
