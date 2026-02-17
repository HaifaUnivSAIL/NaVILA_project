#!/bin/bash
set -e

# -----------------------------
# Configuration
# -----------------------------
HOST_DIR=$(realpath "$(dirname "$0")")
DATASET_DIR=$(realpath "$(dirname "$0")/../../Datasets")

CONTAINER_NAME="navila_container"
IMAGE_NAME="navila_base:latest"

# -----------------------------
# Sanity checks
# -----------------------------
if [[ -z "$DISPLAY" ]]; then
    echo "❌ DISPLAY is not set."
    echo "This script must be run from the local server desktop."
    exit 1
fi

if [[ ! -S "/tmp/.X11-unix/X${DISPLAY#:}" ]]; then
    echo "❌ X11 socket /tmp/.X11-unix/X${DISPLAY#:} not found."
    exit 1
fi

# -----------------------------
# X11 access (Wayland/XWayland compatible)
# -----------------------------
echo "🖥️ Enabling X11 access for Docker (DISPLAY=$DISPLAY)"
xhost +SI:localuser:root >/dev/null

# -----------------------------
# Helper: attach to container
# -----------------------------
attach_container() {
    echo "🟢 Attaching to container with GUI support..."

    exec docker exec -it \
        -e DISPLAY="$DISPLAY" \
        -e QT_X11_NO_MITSHM=1 \
        "${CONTAINER_NAME}" bash
}

# -----------------------------
# Container logic
# -----------------------------
if docker ps -a --format '{{.Names}}' | grep -qx "${CONTAINER_NAME}"; then
    echo "🟡 Container '${CONTAINER_NAME}' already exists."

    if docker ps --format '{{.Names}}' | grep -qx "${CONTAINER_NAME}"; then
        echo "🟢 Container is running."
        attach_container
    else
        echo "🟠 Container exists but is stopped. Starting..."
        docker start "${CONTAINER_NAME}" >/dev/null
        attach_container
    fi
else
    echo "🔵 Container '${CONTAINER_NAME}' does not exist. Creating new container (GUI)..."

    exec docker run --gpus all -it \
        --name "${CONTAINER_NAME}" \
        -v "${HOST_DIR}:/workspace" \
        -v "${DATASET_DIR}:/mnt/dataset" \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -e DISPLAY="$DISPLAY" \
        -e QT_X11_NO_MITSHM=1 \
        -e NVIDIA_DRIVER_CAPABILITIES=all \
        -w /workspace \
        --net=host \
        --ipc=host \
        "${IMAGE_NAME}" \
        bash
fi

