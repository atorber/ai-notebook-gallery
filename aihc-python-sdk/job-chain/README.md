# Job Chain

## 简介
Job-Chain是一个用于管理AIHC任务的工具，它可以帮助用户快速地创建和运行AIHC工作流串行任务。

## 安装依赖

```bash
pip install future
pip install pycryptodome
pip install bce-python-sdk-next

# 或者
pip install -r requirements.txt
```

## 配置API及任务信息

在chain_info.json中配置AIHC API信息和任务信息，具体配置信息如下：

```JSON
{
    "scrips_path": "/root/pfs/dev-test/job-chain/job_chain.py",
    "config_path": "/root/pfs/dev-test/job-chain/examples/job_info/chain_info.json",
    "api_config": {
        "host": "aihc.bj.baidubce.com",
        "ak": "your ak",
        "sk": "your sk"
    },
    "resourcePoolId": "cce-e0isdmib",
    "jobs": [
        {
            "name": "test-api-llama2-7b-4-luyc-job1",
            "queue": "default",
            "priority": "normal",
            "jobFramework": "PyTorchJob",
            "jobSpec": {
                "command": "job1.sh",
                "image": "registry.baidubce.com/aihc-aiak/aiak-megatron:ubuntu20.04-cu11.8-torch1.14.0-py38_v1.2.7.12_release",
                "replicas": 1,
                "envs": [
                    {
                        "name": "CUDA_DEVICE_MAX_CONNECTIONS",
                        "value": "1"
                    }
                ]
            },
            "datasources": [
                {
                    "type": "pfs",
                    "name": "pfs-oYQuh4",
                    "mountPath": "/root/pfs"
                }
            ]
        },
        ...
    ]
}
```

参数说明：

- `scrips_path`: job_chain.py的路径
- `config_path`: 任务配置文件的路径
- `api_config`: AIHC API配置信息，包括主机地址、AK和SK
- `resourcePoolId`: 资源池ID
- `jobs`: 任务列表

在chain_info.json相同目录下创建任务启动脚本job.sh文件，每个任务对应一个job.sh文件，修改为任务的启动命令

## 上传到集群中

将chain_info.json、所有的job.sh以及job_chain.py上传到集群存储中

## 从开始提交串行任务

> 任务提交可以在本地开发PC、集群环境、开发机环境

从第一个任务开始执行，需要指定任务配置文件的路径，当前一个任务执行完成后，会自动创建下一个任务

```bash
python job_chain.py /job-chain/examples/job_info/chain_info.json

## 从指定任务开始执行

从第n个任务开始执行，需要指定任务的索引编号，任务在chain_info.json的索引，从0开始

以下示例为从第二个任务开始创建：

```bash
python job_chain.py /job-chain/examples/job_info/chain_info.json 1
```

## 实现原理

1. 通过调用AIHC API创建任务，并将任务信息存储在chain_info.json中；
2. 从chain_info.json中读取任务信息，将任务信息转换为AIHC API需要的格式；
3. 更新command参数，将job.sh文件中启动命令写入参数中并自动在启动命令最后添加启动下一个任务的脚本。

## AIAK最佳实践

1. 修改aiak_job_info.json中的训练参数

```
{
    "MODEL_NAME": "llama2-7b",
    "REPLICAS": "1",
    "VERSION": "luyc-v4",
    "TRAINING_PHASE": "pretrain",
    "TP": "",
    "PP": "",
    "DATASET_NAME": "pile_llama_test",
    "JSON_KEYS": "text",
    "IMAGE": "registry.baidubce.com/aihc-aiak/aiak-training-llm:ubuntu22.04-cu12.3-torch2.2.0-py310-bccl1.2.7.2_v2.1.1.5_release"
}
```

- 参数说明

|字段名|值|
|--|--|
| MODEL_NAME      | 例如：llama2-7b，在aiak_dict中的models.csv中维护，支持范围参考：https://cloud.baidu.com/doc/AIHC/s/Alyo476jr|
| REPLICAS        | 实例数量|
| VERSION         | 版本，自定义本次训练的版本标识，例如：luyc-v4，最终提交到控制台的任务名称拼接为：{MODEL_NAME}-{VERSION}|
| TRAINING_PHASE  | pretrain、sft|
| TP              | TP切分策略，必须与PP同时设置，不设置时默认使用AIAK推荐默认切分策略|
| PP              | PP切分策略，必须与TP同时设置，不设置时默认使用AIAK推荐默认切分策略|
| DATASET_NAME    | 数据集名称，例如pile_llama_test，在aiak_dict中的datasets.csv中维护|
| JSON_KEYS       | 数据集中的样本字段，例如text|
| IMAGE           | AIAK镜像地址 |

2. 生成aiak任务的chain_info.json配置文件

```
python3 aiak_parameter_generator.py /job-chain/examples/aiak_demo/chain_info.json /job-chain/examples/aiak_demo/aiak_job_info.json
```

3. 使用生成的配置文件提交任务

```
python job_chain.py /job-chain/examples/aiak_demo/chain_info.json
```
