# Base image compatible with RTX 2080 + CUDA 12.4
FROM nvidia/cuda:12.4.1-devel-ubuntu22.04

SHELL ["/bin/bash", "-lc"]

# Set noninteractive to avoid prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV WORKSPACE_DIR=/workspace
ENV PYCHARM_VERSION=2025.1.3.1
ENV TZ=Etc/UTC
ENV PYCHARM_DIR=/opt/pycharm-community-${PYCHARM_VERSION}

# Install system dependencies + GUI support
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential git wget curl cmake python3 python3-pip python3-venv sudo \
    libjpeg-dev libglm-dev libgl1 libglx-mesa0 libgl1-mesa-dri \
    libegl1-mesa-dev libgles2-mesa-dev mesa-utils xorg-dev freeglut3-dev \
    libxrender1 libxtst6 libxi6 libfuse2 openjdk-17-jdk ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh \
    && bash /tmp/miniconda.sh -b -p /opt/conda \
    && rm /tmp/miniconda.sh

# Ensure conda available in all shells
RUN echo "source /opt/conda/etc/profile.d/conda.sh" >> /root/.bashrc \
    && echo "conda activate" >> /root/.bashrc

ENV PATH=/opt/conda/bin:$PATH

# Install PyCharm Community
RUN wget -q https://download.jetbrains.com/python/pycharm-community-${PYCHARM_VERSION}.tar.gz -O /tmp/pycharm.tar.gz \
    && mkdir -p /opt \
    && tar -xzf /tmp/pycharm.tar.gz -C /opt \
    && rm /tmp/pycharm.tar.gz

RUN echo "alias pycharm='${PYCHARM_DIR}/bin/pycharm.sh &'" >> /root/.bashrc

# CUDA paths
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
ENV PATH=/usr/local/cuda/bin:$PATH

WORKDIR $WORKSPACE_DIR

# Make sure .bashrc is loaded
CMD ["/bin/bash", "-l"]


