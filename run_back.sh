#!/bin/bash

# Ensure required variables are set
container_name="ros2_dev"  # Adjust this as needed (make sure it matches your container name)
image_name="amr-ros2-humble"  # Set the correct image name
DOCKER_ARGS=()  # Your Docker arguments

# Start the container
docker run -it \
        --rm \
        ${DOCKER_ARGS[@]} \
        -e DISPLAY=$DISPLAY \
        --runtime=nvidia \
        --gpus all \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -v $PWD/../:/workspaces/amr_ws \
        -v /etc/localtime:/etc/localtime:ro \
        --privileged \
        --name "$container_name" \
        --workdir /workspaces/amr_ws \
        "$image_name" &

# Capture the container ID or name (make sure to set it correctly)
echo "$container_name"
