from launch import LaunchDescription
from launch.actions import IncludeLaunchDescription
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch_ros.actions import Node
from ament_index_python.packages import get_package_share_directory
import os

def generate_launch_description():
    # Paths to individual launch files
    roboteq_driver_launch = os.path.join(
        get_package_share_directory('roboteq_controller'),
        'launch',
        'driver.py'
    )

    lidar_driver_launch = os.path.join(
        get_package_share_directory('pf_driver'),
        'launch',
        'r2000.launch.py'
    )

    robot_description_launch = os.path.join(
        get_package_share_directory('amr_description'),
        'launch',
        'display.launch.py'
    )

    # Include individual launch files
    roboteq_driver = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(roboteq_driver_launch)
    )

    lidar_driver = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(lidar_driver_launch)
    )

    robot_description = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(robot_description_launch)
    )

    return LaunchDescription([
        roboteq_driver,
        lidar_driver,
        robot_description
    ])
