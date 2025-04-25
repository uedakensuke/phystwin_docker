#!/bin/bash
if [ $# -ne 1 ];then
    echo USAGE: process_data.sh case_name
    exit 1
fi

./_process_data.sh $1
./_export_gaussian_data $1

