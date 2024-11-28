import launch,os
import xacro
from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument
from launch.substitutions import LaunchConfiguration
from launch_ros.actions import Node
from ament_index_python.packages import get_package_share_directory

def generate_launch_description():
    desc_share_direcrory= get_package_share_directory("amr_description")
    xacro_path= os.path.join(desc_share_direcrory,"urdf/cad_assembly_amr_final_1.xacro")
    # create urdf from xacro 
    robot_xacro_config = xacro.process_file(xacro_path)
    robot_urdf = robot_xacro_config.toxml()
    rvizconfig=os.path.join(desc_share_direcrory,"urdf/rviz.rviz")
    
    return LaunchDescription([
        
        # Launch joint_state_publisher
        Node(
            package='joint_state_publisher',
            executable='joint_state_publisher',
            name='joint_state_publisher',
            parameters=[{'use_gui': True}]
        ),
        
        # Launch robot_state_publisher
        Node(
            package='robot_state_publisher',
            executable='robot_state_publisher',
            name='robot_state_publisher',
            parameters=[{'robot_description': robot_urdf}]
        ),
        
        # Launch RViz
        Node(
            package='rviz2',
            executable='rviz2',
            name='rviz2',
            arguments=['-d', rvizconfig],
        ),
    ])
