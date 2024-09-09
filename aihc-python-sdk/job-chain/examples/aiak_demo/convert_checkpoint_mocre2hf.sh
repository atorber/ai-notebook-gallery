#! /bin/bash

AIAK_TRAINING_PATH=/workspace/AIAK-Training-LLM
CONVERT_CHECKPOINT_PATH="$AIAK_TRAINING_PATH/tools/convert_checkpoint"
MEGATRON_PATH=${MEGATRON_PATH:-"/workspace/AIAK-Megatron"}

echo "Start to convert checkpoint..."

# 当前不支持 optim 部分转换，通过 --no_save_optim 和 --no_load_optim 关闭；
python $CONVERT_CHECKPOINT_PATH/model.py \
    --load_platform=mcore \
    --save_platform=huggingface \
    --common_config_path=$CONVERT_CHECKPOINT_PATH/config/${MODEL_NAME}.json \
    --tensor_model_parallel_size=${TP} \
    --pipeline_model_parallel_size=${PP} \
    --megatron_path=$MEGATRON_PATH \
    --load_ckpt_path=$LOAD \
    --save_ckpt_path=$SAVE \
    --no_save_optim \
    --no_load_optim

echo "Convert checkpoint done."
