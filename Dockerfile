# Use official Ubuntu 22.04 aarch64 image as the base
FROM arm64v8/ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    ROS_DISTRO=humble \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Update system and install essential tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    gnupg2 \
    lsb-release \
    build-essential \
    apt-utils \
    git \
    usbutils \
    software-properties-common \
    python3-pip \
    nano \
    vim \
    wget \
    sudo \
    locales \
    libcurlpp-dev \
    nvidia-cuda-toolkit \
    && rm -rf /var/lib/apt/lists/*


# # Add the ROS 2 repository and keys
# RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add - && \
#     echo "deb [arch=arm64] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list && \
#     apt-get update

# Install ROS 2 full desktop version
# Download the ROS 2 GPG key and store it in /etc/apt/trusted.gpg.d/
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg

# Add the ROS 2 repository to APT sources
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
# Update the package list to include ROS packages
RUN apt-get update

RUN apt-get install -y --no-install-recommends \
    ros-humble-desktop \
    python3-colcon-common-extensions \
    python3-rosdep \
    python3-vcstool 



# Install ROS 2 Navigation2 and related packages
RUN apt-get install -y --no-install-recommends \
    ros-${ROS_DISTRO}-navigation2 \
    ros-${ROS_DISTRO}-nav2-bringup \
    ros-${ROS_DISTRO}-robot-localization \
    ros-${ROS_DISTRO}-slam-toolbox \
    ros-${ROS_DISTRO}-xacro \
    ros-${ROS_DISTRO}-turtlebot3* \
    ros-${ROS_DISTRO}-teleop-twist-keyboard \
    net-tools \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*
RUN apt-get update
         
# Install additional Python dependencies
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
# Initialize and update rosdep
RUN if [ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]; then \
        rosdep init; \
    fi && \
    rosdep update --include-eol-distros 

# Install dependencies using rosdep
RUN . /opt/ros/$ROS_DISTRO/setup.sh && \
    rosdep install --from-paths src/pf_lidar_ros2_driver --ignore-src --rosdistro=$ROS_DISTRO -y 


# Source ROS 2 setup in the entrypoint
RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> /root/.bashrc
# Create and add the ros_entrypoint.sh script
RUN echo '#!/bin/bash\nsource /opt/ros/humble/setup.bash\nexec "$@"' > /ros_entrypoint.sh && chmod +x /ros_entrypoint.sh

# Set the entrypoint for the container
ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
