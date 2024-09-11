# -*- coding: utf-8 -*-

import sys
from dotenv import load_dotenv
import os

from baidubce.bce_client_configuration import BceClientConfiguration
from baidubce.auth.bce_credentials import BceCredentials
from baidubce.services.aihc.aihc_client import AIHCClient


# 加载.env文件
load_dotenv()

# 获取配置信息, 从环境变量中获取,需要先在.env文件中设置环境变量
AK = os.getenv("AK")
SK = os.getenv("SK")
HOST = os.getenv("HOST")


def generate_aiak_parameter(chain_job_config=None, aiak_job_config=None):

    args = sys.argv[1:]
    if chain_job_config is None or aiak_job_config is None:
        if len(args) < 2:
            print("Usage: python job_chain.py <config_file> [index]")
            return
        else:
            chain_job_config = args[0]
            aiak_job_config = args[1]
    config = BceClientConfiguration(credentials=BceCredentials(AK, SK), endpoint=HOST)
    aihc_client = AIHCClient(config)
    return aihc_client.generate_aiak_parameter(chain_job_config, aiak_job_config)


if __name__ == '__main__':
    generate_aiak_parameter()
