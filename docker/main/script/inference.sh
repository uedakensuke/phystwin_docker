#!/bin/bash
# このコードはoptimize.shを呼んだ後に実行する必要があります
if [ $# -ne 1 ];then
    echo USAGE: inference.sh case_name
    exit 1
fi

TIME0=$(cat /proc/uptime | awk '{print $1}')
./_inference_physics_dense.sh $1
if [ $? -ne 0 ]; then
    exit 1
fi    
TIME1=$(cat /proc/uptime | awk '{print $1}')
./_inference_appearance.sh $1
if [ $? -ne 0 ]; then
    exit 1
fi
TIME2=$(cat /proc/uptime | awk '{print $1}')
./_inference_dynamic.sh $1
if [ $? -ne 0 ]; then
    exit 1
fi    
TIME3=$(cat /proc/uptime | awk '{print $1}')
./_visualize_force.sh $1
if [ $? -ne 0 ]; then
    exit 1
fi    
TIME4=$(cat /proc/uptime | awk '{print $1}')
./_visualize_material.sh $1
if [ $? -ne 0 ]; then
    exit 1
fi    
TIME5=$(cat /proc/uptime | awk '{print $1}')

DIFF1=$(echo "($TIME1 - $TIME0)/60" | bc)min$(echo "($TIME1 - $TIME0)%60" | bc )sec
DIFF2=$(echo "($TIME2 - $TIME1)/60" | bc)min$(echo "($TIME2 - $TIME1)%60" | bc )sec
DIFF3=$(echo "($TIME3 - $TIME2)/60" | bc)min$(echo "($TIME3 - $TIME2)%60" | bc )sec
DIFF4=$(echo "($TIME4 - $TIME3)/60" | bc)min$(echo "($TIME4 - $TIME3)%60" | bc )sec
DIFF5=$(echo "($TIME5 - $TIME4)/60" | bc)min$(echo "($TIME5 - $TIME4)%60" | bc )sec

echo inference_physics_dense: $DIFF1
echo inference_appearance: $DIFF2
echo inference_dynamic: $DIFF3
echo visualize_force: $DIFF4
echo visualize_material: $DIFF5
