#! /bin/bash
# =========================================参数编辑区========================================
# BOS_PATH：原始权重在bos上的路径

MODEL_NAME=llama2-70b
TP=4
PP=4

# LOAD：原始权重地址，SAVE 转换的模型存储路径
LOAD=/mnt/cluster/mcore/meta-llama/Llama-2-70b-hf/tp${TP}_pp${PP}
SAVE=/mnt/cluster/huggingface.co/meta-llama/Llama-2-70b-hf/

load_platform=mcore
save_platform=huggingface
# ==========================================================================================

AIAK_TRAINING_PATH=/workspace/AIAK-Training-LLM
CONVERT_CHECKPOINT_PATH="$AIAK_TRAINING_PATH/tools/convert_checkpoint"
MEGATRON_PATH=${MEGATRON_PATH:-"/workspace/AIAK-Megatron"}

echo "Start to convert checkpoint..."

# 当前不支持 optim 部分转换，通过 --no_save_optim 和 --no_load_optim 关闭；
python $CONVERT_CHECKPOINT_PATH/model.py \
    --load_platform=${load_platform} \
    --save_platform=${save_platform} \
    --common_config_path=$CONVERT_CHECKPOINT_PATH/config/${MODEL_NAME}.json \
    --tensor_model_parallel_size=${TP} \
    --pipeline_model_parallel_size=${PP} \
    --load_ckpt_path=$LOAD \
    --save_ckpt_path=$SAVE \
    --megatron_path=$MEGATRON_PATH \
    --no_save_optim \
    --no_load_optim \
    --safetensors

echo "Convert checkpoint done."
