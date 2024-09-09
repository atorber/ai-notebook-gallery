#!/bin/bash

set -e

# 镜像地址：
# registry.baidubce.com/aihc-aiak/aiak-training-llm:ubuntu22.04-cu12.3-torch2.2.0-py310-bccl1.2.7.2_v2.1.1.5_release

# PFS挂载路径
# /workspace/pfs

# Log function to capture script steps
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

RUN_JUPYTER=1
JUPYTER_TOKEN=${JUPYTER_TOKEN:-"b5991a5f456f820c0cf48a00691ae11434b6c32633e07dea"}
log "Jupyter token: $JUPYTER_TOKEN"

JUPYTER_PORT=${JUPYTER_PORT:-"8600"}
log "JupyterLab port: $JUPYTER_PORT"

JUPYTERLAB_BASE_URL=${JUPYTERLAB_BASE_URL}
log "JupyterLab base URL: $JUPYTERLAB_BASE_URL"

WORKDIR="/workspace"
JUPYTER_CONFIG_DIR="$WORKDIR/.jupyter"

# Install node.js
log "Setting up Node.js..."
curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
if [ $? -ne 0 ]; then
    log "Failed to set up Node.js repository"
    exit 1
fi
apt-get install -y nodejs
if [ $? -ne 0 ]; then
    log "Failed to install Node.js"
    exit 1
fi

log "Starting script..."

# Create Jupyter config directory
log "Creating Jupyter config directory..."
mkdir -p "$JUPYTER_CONFIG_DIR"
CONFIG_FILE="$JUPYTER_CONFIG_DIR/jupyter_notebook_config.py"

log "Generating Jupyter config file..."
cat <<EOL > $CONFIG_FILE
import os
c = get_config()
c.NotebookApp.allow_remote_access = True
c.NotebookApp.allow_root = True
c.NotebookApp.terminado_settings = {'shell_command' : ['/bin/bash']}
c.LabApp.base_url = os.environ.get("JUPYTERLAB_BASE_URL", "/jupyter")
c.LabApp.ip = '0.0.0.0'
c.LabApp.port = os.environ.get("JUPYTER_PORT", "8600")
c.LabApp.terminado_settings = {'shell_command' : ['/bin/bash']}
c.NotebookApp.notebook_dir = ${WORKDIR}
EOL

# Install Python packages
log "Installing JupyterLab and additional Python packages..."
pip install jupyterlab -i https://pypi.tuna.tsinghua.edu.cn/simple
pip install jupyterlab-language-pack-zh-CN -i https://pypi.tuna.tsinghua.edu.cn/simple
pip install jupytext -i https://pypi.tuna.tsinghua.edu.cn/simple

if [ $? -ne 0 ]; then
    log "Failed to install Python packages"
    exit 1
else
    log "Python packages installed successfully"
fi

# Start JupyterLab
log "Starting JupyterLab..."
nohup jupyter-lab --no-browser --NotebookApp.token="${JUPYTER_TOKEN}" --port=8600 --ip=0.0.0.0 --NotebookApp.base_url="${JUPYTERLAB_BASE_URL}" --notebook-dir="${WORKDIR}" > /workspace/.jupyter/jupyter.log 2>&1 &
if [ $? -ne 0 ]; then
    log "Failed to start JupyterLab"
    exit 1
else
    log "JupyterLab started successfully"
fi

# Block the script and keep the process running
while true; do
    log "JupyterLab is running..."
    sleep 60
done