#!/bin/bash
# このコードはprocess_data.shを呼んだ後に実行する必要があります
if [ $# -ne 1 ];then
    echo USAGE: optimize.sh case_name
    exit 1
fi

TIME0=$(cat /proc/uptime | awk '{print $1}')
./_optimize_physics_sparse.sh $1
if [ $? -ne 0 ]; then
    exit 1
fi    
TIME1=$(cat /proc/uptime | awk '{print $1}')
./_optimize_physics_dence.sh $1
if [ $? -ne 0 ]; then
    exit 1
fi    
TIME2=$(cat /proc/uptime | awk '{print $1}')
./_optimize_appearance.sh $1
if [ $? -ne 0 ]; then
    exit 1
fi    
TIME3=$(cat /proc/uptime | awk '{print $1}')

DIFF1=$(echo "($TIME1 - $TIME0)/60" | bc)min$(echo "($TIME1 - $TIME0)%60" | bc )sec
DIFF2=$(echo "($TIME2 - $TIME1)/60" | bc)min$(echo "($TIME2 - $TIME1)%60" | bc )sec
DIFF3=$(echo "($TIME3 - $TIME2)/60" | bc)min$(echo "($TIME3 - $TIME2)%60" | bc )sec

echo optimize_physics_coarse: $DIFF1
echo optimize_physics_dence: $DIFF2
echo optimize_appearance: $DIFF3
