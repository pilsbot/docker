FROM dustynv/ros:foxy-slam-l4t-r32.4.4

# taken from https://github.com/athackst/dockerfiles/blob/main/ros2/foxy.Dockerfile

ENV DEBIAN_FRONTEND=noninteractive

# Fix expired gpg key
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null \
  | gpg --dearmor - \
  | sudo tee /usr/share/keyrings/kitware-archive-keyring.gpg > /dev/null \
  && echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ bionic main' \
  | sudo tee /etc/apt/sources.list.d/kitware.list >/dev/null

# Install language
RUN apt-get update && apt-get install -y \
  locales \
  && locale-gen en_US.UTF-8 \
  && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
  && rm -rf /var/lib/apt/lists/*
ENV LANG en_US.UTF-8

# Install timezone
RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime \
  && export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get install -y tzdata \
  && dpkg-reconfigure --frontend noninteractive tzdata \
  && rm -rf /var/lib/apt/lists/*

ENV ROS_DISTRO=foxy
ENV AMENT_PREFIX_PATH=/opt/ros/foxy/install
ENV COLCON_PREFIX_PATH=/opt/ros/foxy/install
ENV LD_LIBRARY_PATH=/opt/ros/foxy/install/lib
ENV PATH=/opt/ros/foxy/install/bin:$PATH
ENV PYTHONPATH=/opt/ros/foxy/install/lib/python3.6/site-packages
ENV ROS_PYTHON_VERSION=3
ENV ROS_VERSION=2
ENV DEBIAN_FRONTEND=

ARG USERNAME=ros
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create a non-root user
RUN groupadd --gid $USER_GID $USERNAME \
  && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
  # [Optional] Add sudo support for the non-root user
  && apt-get update \
  && apt-get install -y sudo \
  && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
  && chmod 0440 /etc/sudoers.d/$USERNAME \
  # Cleanup
  && rm -rf /var/lib/apt/lists/* \
  && echo "source /usr/share/bash-completion/completions/git" >> /home/$USERNAME/.bashrc \
  && echo "if [ -f /opt/ros/${ROS_DISTRO}/install/setup.bash ]; then source /opt/ros/${ROS_DISTRO}/install/setup.bash; fi" >> /home/$USERNAME/.bashrc

ENV DEBIAN_FRONTEND=
ENV AMENT_CPPCHECK_ALLOW_SLOW_VERSIONS=1

RUN mkdir -p /workspaces/addon_ws/src
WORKDIR /workspaces/addon_ws

RUN apt-get update && apt-get -y install libusb-1.0-0-dev \
    && rm -rf /var/lib/apt/lists/*

RUN export MAKEFLAGS="-j$(nproc)" && cd /tmp && git clone --recursive https://github.com/luxonis/depthai-core.git --branch main \
    && cmake -Hdepthai-core -Bdepthai-core/build -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=/usr/local \
    && cmake --build depthai-core/build --target install --parallel $(nproc) \
    && cd /tmp \
    && rm -r depthai-core

RUN cd src && git clone -b ${ROS_DISTRO} https://github.com/ros-controls/ros2_control.git \
    && git clone -b ${ROS_DISTRO}-devel https://github.com/ros-controls/control_msgs.git \
    && git clone -b ${ROS_DISTRO}-devel https://github.com/ros-controls/realtime_tools.git \
    && git clone -b ros2 https://github.com/ros-drivers/ackermann_msgs.git \
    && git clone -b ${ROS_DISTRO}-devel https://github.com/ros/angles.git \
    && git clone -b ${ROS_DISTRO} https://github.com/ros-controls/ros2_controllers.git \
    && git clone https://github.com/ros-controls/control_toolbox.git \
    && git clone -b ${ROS_DISTRO} https://github.com/luxonis/depthai-ros.git \
    && git clone -b ${ROS_DISTRO} https://github.com/ros/joint_state_publisher.git \
    && git clone -b ${ROS_DISTRO} https://github.com/ros2/teleop_twist_joy.git \
    && git clone -b ${ROS_DISTRO}-devel https://github.com/ros-drivers/joystick_drivers.git
    # && git clone -b ${ROS_DISTRO} https://github.com/ros2/rviz.git \
    # && git clone -b ros2 https://github.com/ros-visualization/rqt.git \
    # && git clone -b ${ROS_DISTRO}-devel https://github.com/ros-visualization/qt_gui_core.git

RUN apt-get update && rosdep install --from-paths src --ignore-src -r -y --skip-keys=libopencv-dev\
     && rm -rf /var/lib/apt/lists/*

RUN source /opt/ros/foxy/install/setup.bash && \
    colcon build --merge-install --symlink-install --cmake-args '-DCMAKE_BUILD_TYPE=Release' \
    '-DCMAKE_EXPORT_COMPILE_COMMANDS=On' '-DBUILD_TESTING=OFF' -Wall -Wextra -Wpedantic \
    && rm -r build/ log/ src/

COPY ./ros_entrypoint.sh /

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
