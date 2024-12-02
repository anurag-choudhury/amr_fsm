from ament_index_python.packages import get_package_share_directory
from launch.substitutions import LaunchConfiguration
from launch.actions import IncludeLaunchDescription,DeclareLaunchArgument
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch import LaunchDescription
from launch_ros.actions import Node
from launch.conditions import IfCondition
import os

def generate_launch_description():
    pkg_amr_nav=get_package_share_directory("amr_nav")
    pkg_nav2_bringup=get_package_share_directory("nav2_bringup")
    path_yaml= os.path.join(pkg_amr_nav, 'maps', 'map_save.yaml')
    use_sim_time = LaunchConfiguration('use_sim_time', default='true')
    with_rviz = LaunchConfiguration('with_rviz', default='true')
    rviz_config=os.path.join(pkg_amr_nav,"config","nav_rviz.rviz")
    map_yaml_file = LaunchConfiguration('map',
                default=os.path.join(pkg_amr_nav, 'maps', 'map_save.yaml'))
    nav2_config_file = LaunchConfiguration('params', 
                    default=os.path.join(pkg_amr_nav, 'params', 'nav2_params.yaml'))
    
    nav2_bringup_launch_file = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(os.path.join(pkg_nav2_bringup,"launch","bringup_launch.py")),
        launch_arguments={
            "map":map_yaml_file,
            "use_sim_time":use_sim_time,
            "params_file":nav2_config_file
        }.items()
    )
    rviz = Node(package='rviz2',
                executable='rviz2',
                name='rviz',
    #				output='screen',
                arguments=['-d' + rviz_config],
                condition=IfCondition(with_rviz)
                )
    return LaunchDescription([
        # DeclareLaunchArgument("map",default_value=os.path.join(pkg_amr_nav, 'maps', 'map_save.yaml') ,description="map.yaml file"),
        DeclareLaunchArgument("params_file",default_value=nav2_config_file,description="params for nav2"),
        DeclareLaunchArgument("use_sim_time",default_value=use_sim_time,description="sim_time true or false"),
        nav2_bringup_launch_file
    ])