from launch import LaunchDescription
from launch_ros.actions import Node
from ament_index_python.packages import get_package_share_directory
import os
from launch.actions import TimerAction
import xacro

def generate_launch_description():
    bringup_share_direcrory = get_package_share_directory("amr_bringup")
    controller_params= os.path.join(bringup_share_direcrory,"config/diff_drive_controller.yaml")
    desc_share_direcrory= get_package_share_directory("amr_description")
    xacro_path= os.path.join(desc_share_direcrory,"urdf/cad_assembly_amr_final_1.xacro")
    # create urdf from xacro 
    robot_xacro_config = xacro.process_file(xacro_path)
    robot_urdf = robot_xacro_config.toxml()
    
    return LaunchDescription([
        # # Launch the controller_manager node
        Node(
            package='controller_manager',
            executable='ros2_control_node',
            output='screen',
        ),
        # Load the joint state controller
                # Delay the spawners to ensure controller_manager has loaded
        TimerAction(
            period=2.0,  # Wait 2 seconds
            actions=[Node(
                package='controller_manager',
                executable='spawner',
                arguments=['joint_state_controller', '--param-file', controller_params],
                output='screen',
            )]
        ),
        #oad the position controller for joint_right
        Node(
            package='controller_manager',
            executable='spawner',
            arguments=['joint_right_position_controller', '--param-file', controller_params],
            output='screen',
        ),
        # Load the position controller for left_joint
        Node(
            package='controller_manager',
            executable='spawner',
            arguments=['left_joint_position_controller', '--param-file', controller_params],
            output='screen',
        ),
    ])
