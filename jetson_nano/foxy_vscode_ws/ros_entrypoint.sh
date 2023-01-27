#!/bin/bash
set -e

# setup ros2 environment
source "/workspaces/addon_ws/install/setup.bash"
exec "$@"
