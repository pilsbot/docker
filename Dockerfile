FROM nvcr.io/nvidia/l4t-base:r32.4.4

ARG ROS_DISTRO=dashing
ARG ROS_PATH=/opt/ros/$ROS_DISTRO/

RUN apt-get update && apt-get upgrade -y && apt-get install -y git curl gnupg2 lsb-release
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -
RUN sh -c 'echo "deb [arch=$(dpkg --print-architecture)] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list'

ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y ros-$ROS_DISTRO-desktop python3-rosdep python3-colcon-common-extensions
RUN rosdep init && rosdep update

RUN mkdir -p /home/pilsbot/workspace/src

ARG WORKSPACE=/home/pilsbot/workspace
WORKDIR $WORKSPACE/src

RUN git clone --branch $ROS_DISTRO https://github.com/ros-perception/vision_opencv.git
RUN git clone --branch $ROS_DISTRO https://github.com/ros-perception/image_common.git

WORKDIR $WORKSPACE

RUN . $ROS_PATH/setup.sh && rosdep install --from-paths src --ignore-src -r -y
RUN . $ROS_PATH/setup.sh && colcon build

COPY ./ros_entrypoint.sh /
COPY ./camera.yaml /root/.ros/camera_info/

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]

