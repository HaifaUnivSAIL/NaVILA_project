#!/bin/bash
set -e

# -----------------------------
# Argument parsing
# -----------------------------
REMOTE_MODE=0
if [[ "$1" == "--remote" ]]; then
    REMOTE_MODE=1
fi

HOST_DIR=$(realpath "$(dirname "$0")")
DATASET_DIR=$(realpath "$(dirname "$0")/../../Datasets")

CONTAINER_NAME="navila_container"
IMAGE_NAME="navila_base:latest"

# -----------------------------
# Environment setup
# -----------------------------
if [[ $REMOTE_MODE -eq 1 ]]; then
    echo "🚀 REMOTE MODE: Headless EGL rendering"

    # Absolutely NO X11
    unset DISPLAY
    export DISPLAY=""

    # Force EGL offscreen rendering (Habitat-Sim / Magnum)
    export MAGNUM_GL_CONTEXT=egl
    export MAGNUM_GPU_VALIDATION=off
    export HABITAT_SIM_LOG=quiet
else
    echo "🖥️ LOCAL MODE: GUI (X11) rendering"

    # Enable X11
    export DISPLAY
    xhost +local:root >/dev/null
fi

# -----------------------------
# Helper: attach to container
# -----------------------------
attach_container() {
    echo "🟢 Attaching to container..."
    exec docker exec -it "${CONTAINER_NAME}" bash
}

# -----------------------------
# Check if container exists
# -----------------------------
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "🟡 Container '${CONTAINER_NAME}' already exists."

    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo "🟢 Container is running."
        attach_container
    else
        echo "🟠 Container exists but is stopped. Starting..."
        docker start "${CONTAINER_NAME}" >/dev/null
        attach_container
    fi

else
    echo "🔵 Container '${CONTAINER_NAME}' does not exist. Creating new container..."

    if [[ $REMOTE_MODE -eq 1 ]]; then
        echo "🚀 Creating container in REMOTE (EGL headless) mode"

        docker run --gpus all -d \
            --name "${CONTAINER_NAME}" \
            -v "${HOST_DIR}:/workspace" \
            -v "${DATASET_DIR}:/mnt/dataset" \
            -e DISPLAY="" \
            -e MAGNUM_GL_CONTEXT=egl \
            -e MAGNUM_GPU_VALIDATION=off \
            -e HABITAT_SIM_LOG=quiet \
            -e NVIDIA_DRIVER_CAPABILITIES=all \
            -w /workspace \
            --net=host \
            --ipc=host \
            "${IMAGE_NAME}" \
            tail -f /dev/null

        # Ensure container PID 1 is alive before exec
        sleep 2
        attach_container

    else
        echo "🖥️ Creating container in LOCAL (GUI/X11) mode"

        docker run --gpus all -it \
            --name "${CONTAINER_NAME}" \
            -v "${HOST_DIR}:/workspace" \
            -v "${DATASET_DIR}:/mnt/dataset" \
            -v /tmp/.X11-unix:/tmp/.X11-unix \
            -e DISPLAY="${DISPLAY}" \
            -e QT_X11_NO_MITSHM=1 \
            -e NVIDIA_DRIVER_CAPABILITIES=all \
            -w /workspace \
            --net=host \
            --ipc=host \
            "${IMAGE_NAME}" \
            bash
    fi
fi
