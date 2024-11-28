# Use official ROS2 Humble base image with Ubuntu 22.04
FROM ros:humble

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    ROS_DISTRO=humble \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Update and install required dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    python3-pip \
    python3-colcon-common-extensions \
    python3-rosdep \
    python3-vcstool \
    curl \
    nano \
    vim \
    wget \
    sudo \
    lsb-release \
    gnupg2 \
    libcurlpp-dev \
    locales \
    && rm -rf /var/lib/apt/lists/*

# Install ROS 2 Navigation2 and related packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-${ROS_DISTRO}-navigation2 \
    ros-${ROS_DISTRO}-nav2-bringup \
    ros-${ROS_DISTRO}-robot-localization \
    ros-${ROS_DISTRO}-slam-toolbox \
    ros-${ROS_DISTRO}-xacro \
    && rm -rf /var/lib/apt/lists/*

# Install TurtleBot3 and other essential tools for hardware setup
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-${ROS_DISTRO}-turtlebot3* \
    net-tools \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*
# Install full ROS 2 desktop
RUN apt-get update && apt-get install -y \
    ros-humble-desktop \
    && rm -rf /var/lib/apt/lists/*

# Install teleop_twist_keyboard and other useful ROS tools
RUN apt-get update && apt-get install -y \
    ros-humble-teleop-twist-keyboard \
    ros-humble-xacro \
    && rm -rf /var/lib/apt/lists/*
# Install additional Python dependencies if needed
RUN pip3 install --no-cache-dir \
    numpy \
    scipy \
    matplotlib

# Set up workspace directory
WORKDIR /home/ros2_ws
RUN mkdir -p src
# Copy your ROS 2 packages into the workspace
COPY ./ ./src
RUN apt-get update
# Initialize rosdep only if not already initialized
RUN if [ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]; then \
        rosdep init; \
    fi && \
    rosdep update --include-eol-distros 
    
# Install dependencies using rosdep, skipping ros-humble-io-context
RUN . /opt/ros/$ROS_DISTRO/setup.sh && \
    rosdep install --from-paths src/pf_lidar_ros2_driver --ignore-src --rosdistro=$ROS_DISTRO -y 


# Source ROS 2 setup in the entrypoint
RUN echo "source /opt/ros/humble/setup.bash" >> /root/.bashrc

# Set the entrypoint for the container
ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
