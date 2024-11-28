#!/bin/bash

# Docker container name
container_name="ros2_dev"

# Check if the container is running
if docker ps --format '{{.Names}}' | grep -q "$container_name"; then
    echo "Attaching to container: $container_name"
    docker exec -it $container_name /bin/bash
else
    echo "Container $container_name is not running. Start it first using ./run.sh."
fi
