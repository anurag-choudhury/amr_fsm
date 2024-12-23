#!/bin/bash

# Define your container name and image name
container_name="ros2_dev"
image_name="amr-ros2-humble"

# Start the container with a long-running process (e.g., bash shell or ros2 node launcher)
docker run -d \
    --runtime=nvidia \
    --gpus all \
    --network=host \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v $PWD/../:/workspaces/amr_ws \
    -v /etc/localtime:/etc/localtime:ro \
    --privileged \
    --name "$container_name" \
    --workdir /workspaces/amr_ws \
    "$image_name" bash -c "source /opt/ros/humble/setup.bash && tail -f /dev/null"  # Keeps container alive with a dummy process

# Ensure the container is running
echo "Waiting for container $container_name to start..."
while ! docker ps --filter "name=$container_name" | grep -q $container_name; do
    echo "Container $container_name not running yet, retrying..."
    sleep 2
done
echo "Container $container_name is now running."

# Trap to ensure cleanup on script exit (removes container)
trap 'echo "Cleaning up..."; docker stop "$container_name"; docker rm -f "$container_name"; exit 0' EXIT

# Launch the robot bringup
docker exec $container_name bash -c "source /opt/ros/humble/setup.bash && source /workspaces/amr_ws/install/setup.bash && ros2 launch amr_bringup robot_bringup.launch.py" || { echo "Failed to launch robot_bringup"; exit 1; } &
ROBOT_PID=$!

# Launch the navigation
docker exec $container_name bash -c "source /opt/ros/humble/setup.bash && source /workspaces/amr_ws/install/setup.bash && ros2 launch amr_nav navigation.launch.py" || { echo "Failed to launch navigation"; exit 1; } &
NAV_PID=$!

# Wait for both tasks to complete
# This allows you to gracefully exit the script, but also ensures the processes are monitored
wait $ROBOT_PID
wait $NAV_PID

echo "Both tasks completed successfully!"

# Cleanup (docker stop + rm) will automatically happen when the script exits due to the trap
