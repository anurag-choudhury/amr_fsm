
from launch import LaunchDescription
from launch_ros.actions import Node
from ament_index_python.packages import get_package_share_directory
import os

def generate_launch_description():
    nav_pkg_dir=get_package_share_directory("amr_nav")
    ekf_param_file= os.path.join(nav_pkg_dir,"params/ekf_params.yaml")
    return LaunchDescription([
        Node(
            package='robot_localization',
            executable='ekf_node',
            name='ekf_filter_node',
            output='screen',
            parameters=[ekf_param_file]
        ),
    ])
