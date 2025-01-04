#!/bin/bash

# Ensure the environment is properly sourced for ROS 2
echo "Setting up ROS 2 environment..."
source /opt/ros/foxy/setup.bash
source ~/amr_fsm_anurag_ws/install/setup.bash

# Function to ensure that the ROS 2 node is running
start_ros2_launch() {
    local launch_file=$1
    echo "Launching $launch_file..."
    ros2 launch $launch_file || { echo "Failed to launch $launch_file"; exit 1; }
}

# Launch the robot bringup in the background
ros2 launch amr_bringup robot_bringup.launch.py &
ROBOT_PID=$!

# Launch the navigation in the background
ros2 launch amr_nav navigation.launch.py &
NAV_PID=$!

# Wait for both tasks to complete
wait $ROBOT_PID
wait $NAV_PID

echo "Both tasks completed successfully!"

# Cleanup actions can be added here if needed
