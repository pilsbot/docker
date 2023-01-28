# docker
Docker development repository

If building the aarch64 image for jetson nano, follow these steps to build over qemu:
https://www.stereolabs.com/docs/docker/building-arm-container-on-x86/

Basically, run:
```bash
sudo apt-get install qemu binfmt-support qemu-user-static # Install the qemu packages
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes # This step will execute the registering scripts

docker run --rm -t arm64v8/ubuntu uname -m # Testing the emulation environment
#aarch64
```
