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
    realsense_launch = os.path.join(
        get_package_share_directory('realsense2_camera'),
        'launch',
        'rs_launch.py'
    )
    odom_ekf_filter_launch = os.path.join(
        get_package_share_directory('amr_nav'),
        "launch","odom_filter.launch.py"
    )
    realsense_camera = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(realsense_launch),
        launch_arguments={
            'enable_depth': 'false',
            'enable_color': 'false',
            'enable_infra1': 'false',
            'enable_infra2': 'false',
            'enable_gyro': 'true',
            'enable_accel': 'true',
            'unite_imu_method': '1'
        }.items()
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
    odom_fused = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(odom_ekf_filter_launch)
    )
    filtered_laser_scan = Node(
        package='filtered_laser_scan',
        executable='bounding_box_laser',
        name="filtered_laser_scan"
    )
    obstacle_stop_node =Node(
        package='amr_nav',
        executable="obstacle_stop.py",
        name="obstacle_stop_node"
    )
    

    return LaunchDescription([
        roboteq_driver,
        lidar_driver,
        robot_description,
        filtered_laser_scan,
        obstacle_stop_node,
        realsense_camera,
        odom_fused
    ])
