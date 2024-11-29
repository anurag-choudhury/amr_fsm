cmake_minimum_required(VERSION 3.8)
project(filtered_laser_scan)

if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic)
endif()

# Find dependencies
find_package(ament_cmake REQUIRED)
find_package(rclcpp REQUIRED)
find_package(sensor_msgs REQUIRED)
# find_package(perception_pcl REQUIRED)
# find_package(PCL REQUIRED)
# find_package(pcl_conversions REQUIRED)

# Add executable after finding all dependencies
add_executable(bounding_box_laser scripts/bounding_box_laser.cpp)

# Link libraries
ament_target_dependencies(bounding_box_laser rclcpp sensor_msgs )

# Install target
install(TARGETS bounding_box_laser
        DESTINATION lib/${PROJECT_NAME})

if(BUILD_TESTING)
  find_package(ament_lint_auto REQUIRED)
  set(ament_cmake_copyright_FOUND TRUE)
  set(ament_cmake_cpplint_FOUND TRUE)
  ament_lint_auto_find_test_dependencies()
endif()

ament_package()
