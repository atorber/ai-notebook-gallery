# -*- coding: utf-8 -*-
import sys
import json
import os
import time
import logging
from baidubce.services.aihc.aihc_client import AIHCClient

import baidubce.protocol
from baidubce.bce_client_configuration import BceClientConfiguration
from baidubce.auth.bce_credentials import BceCredentials


# 配置日志
logging.basicConfig(level=logging.INFO,
                    format='%(asctime)s - %(levelname)s - %(message)s')


def load_config(config_file):
    if not os.path.exists(config_file):
        raise FileNotFoundError(f"File {config_file} not found.")
    with open(config_file, 'r') as f:
        return json.load(f)


def create_job_chain(config_file=None, index=None):
    args = sys.argv[1:]
    if config_file is None:
        if len(args) < 1:
            logging.error("Usage: python job_chain.py <config_file> [index]")
            return
        else:
            config_file = args[0]
    if index is None:
        try:
            index = int(args[1]) if len(args) > 1 else 0
        except ValueError:
            logging.error("Invalid index value.")

    job_info = load_config(config_file)
    # print('job_info: ', job_info)
    api_config = job_info['api_config']
    print('api_config: ', api_config)

    client_token = 'test-aihc-' + str(int(time.time()))
    logging.info('client_token: %s', client_token)
    config = BceClientConfiguration(
        credentials=BceCredentials(api_config['ak'], api_config['sk']),
        endpoint=api_config['host'],
        protocol=baidubce.protocol.HTTPS
    )

    aihc_client = AIHCClient(config)

    # 获取任务列表
    chain_job_info = aihc_client.create_job_chain(config_file, index)
    print('chain_job_info: ', chain_job_info)
    return chain_job_info


if __name__ == "__main__":
    create_job_chain()
