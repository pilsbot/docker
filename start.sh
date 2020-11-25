docker run --runtime nvidia --network host -it -e DISPLAY=$DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix/ -v /tmp/argus_socket:/tmp/argus_socket --cap-add SYS_PTRACE --mount type=bind,source=/home/pilsbot/pilsbot_docker/workspace/src/jetson_camera,target=/home/pilsbot/workspace/src/jetson_camera --device /dev/video0:/dev/video0 l4t-base:ros2