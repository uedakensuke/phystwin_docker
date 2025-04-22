#!/bin/bash
# このコードはinference.shを呼んだ後に実行する必要があります
if [ $# -ne 1 ];then
    echo USAGE: eval.sh case_name
    exit 1
fi

./_export_render_eval_data.sh $1
./_visualize_render_results.sh $1

# Get the quantative results
./_evaluate.sh $1
