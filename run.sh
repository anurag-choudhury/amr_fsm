#!/bin/bash

# Map host's display socket to Docker for GUI applications
DOCKER_ARGS+=("-v $HOME/.Xauthority:/root/.Xauthority:rw")
DOCKER_ARGS+=("-e DISPLAY")
DOCKER_ARGS+=("-e LIBGL_ALWAYS_SOFTWARE=1") # Enable software rendering by default
DOCKER_ARGS+=("--privileged") # Required for USB and network access
DOCKER_ARGS+=("--network=host") # Share host's network stack

# Allow connections to X server
xhost +local:root

# Docker image and container configuration
image_name="amr-ros2-humble"
container_name="ros2_dev"

# Check for NVIDIA GPU support
if command -v nvidia-smi &>/dev/null && nvidia-smi -L &>/dev/null; then
    echo "NVIDIA GPU detected. Configuring for NVIDIA runtime..."
    DOCKER_ARGS+=("--runtime=nvidia")
    DOCKER_ARGS+=("-e NVIDIA_VISIBLE_DEVICES=all")
    DOCKER_ARGS+=("-e NVIDIA_DRIVER_CAPABILITIES=all")
else
    echo "No NVIDIA GPU detected. Configuring for software rendering..."
    DOCKER_ARGS+=("-e LIBGL_ALWAYS_SOFTWARE=1") # Ensure software rendering
fi

# Check if the container is already running
if docker ps --format '{{.Names}}' | grep -q "$container_name"; then
    echo "Container is already running. Attaching to it..."
    docker exec -it $container_name /bin/bash
else
    echo "Starting a new container..."
    docker run -it --rm \
        ${DOCKER_ARGS[@]} \
        -e DISPLAY=$DISPLAY \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -v $PWD/../:/workspaces/amr_ws \
        -v /etc/localtime:/etc/localtime:ro \
        --privileged \
        --name "$container_name" \
        --workdir /workspaces/amr_ws \
        "$image_name" \
        /bin/bash
fi
