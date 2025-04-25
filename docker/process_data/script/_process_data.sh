#!/bin/bash
echo "------------------START: process_data"
echo "case_name: $1"

./vglrun.sh "python PhysTwin/process_data.py \
    --raw_path mount/ws/raw \
    --base_path mount/ws/data/different_types \
    --case_name $1
    $2"

if [ $? -ne 0 ]; then
    echo "process_dataに失敗しました"
    exit 1
fi

echo "------------------END: process_data"
