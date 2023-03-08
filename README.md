rtabmap
=======

[![RTAB-Map Logo](https://raw.githubusercontent.com/introlab/rtabmap/master/guilib/src/images/RTAB-Map100.png)](http://introlab.github.io/rtabmap)

[![Release][release-image]][releases]
[![License][license-image]][license]

[release-image]: https://img.shields.io/badge/release-0.20.16-green.svg?style=flat
[releases]: https://github.com/introlab/rtabmap/releases

[license-image]: https://img.shields.io/badge/license-BSD-green.svg?style=flat
[license]: https://github.com/introlab/rtabmap/blob/master/LICENSE

RTAB-Map library and standalone application.

 * For more information (e.g., papers, major updates), visit [RTAB-Map's home page](http://introlab.github.io/rtabmap).
 * For installation instructions and examples, visit [RTAB-Map's wiki](https://github.com/introlab/rtabmap/wiki).

To use RTAB-Map under ROS, visit the [rtabmap](http://wiki.ros.org/rtabmap) page on the ROS wiki.

### Acknowledgements
This project is supported by [IntRoLab - Intelligent / Interactive / Integrated / Interdisciplinary Robot Lab](https://introlab.3it.usherbrooke.ca/), Sherbrooke, Québec, Canada.

<a href="https://introlab.3it.usherbrooke.ca/">
<img src="https://github.com/introlab/16SoundsUSB/blob/master/images/IntRoLab.png" alt="IntRoLab" height="100">
</a>

#### CI Latest

  <table>
    <tbody>
        <tr>
           <td>Linux</td>
           <td><a href="https://github.com/introlab/rtabmap/actions/workflows/cmake.yml"><img src="https://github.com/introlab/rtabmap/actions/workflows/cmake.yml/badge.svg" alt="Build Status"/> <br> <a href="https://github.com/introlab/rtabmap/actions/workflows/cmake-ros.yml"><img src="https://github.com/introlab/rtabmap/actions/workflows/cmake-ros.yml/badge.svg" alt="Build Status"/> <br> <a href="https://github.com/introlab/rtabmap/actions/workflows/docker.yml"><img src="https://github.com/introlab/rtabmap/actions/workflows/docker.yml/badge.svg" alt="Build Status"/>
           </td>
        </tr>
        <tr>
           <td>Windows</td>
           <td><a href="https://ci.appveyor.com/project/matlabbe/rtabmap/branch/master"><img src="https://ci.appveyor.com/api/projects/status/hr73xspix9oqa26h/branch/master?svg=true" alt="Build Status"/>
           </td>
        </tr>
     </tbody>
  </table>
 
 #### ROS Binaries
 
 `ros-$ROS_DISTRO-rtabmap`
 
 <table>
    <tbody>
        <tr>
           <td rowspan="2">ROS 1</td>
           <td>Melodic</td>
            <td><a href="http://build.ros.org/job/Mbin_ubv8_uBv8__rtabmap__ubuntu_bionic_arm64__binary/"><img src="http://build.ros.org/buildStatus/icon?job=Mbin_ubv8_uBv8__rtabmap__ubuntu_bionic_arm64__binary" alt="Build Status"/></td>
        </tr>
        <tr>
            <td>Noetic</td>
            <td><a href="http://build.ros.org/job/Nbin_ufv8_uFv8__rtabmap__ubuntu_focal_arm64__binary/"><img src="http://build.ros.org/buildStatus/icon?job=Nbin_ufv8_uFv8__rtabmap__ubuntu_focal_arm64__binary" alt="Build Status"/></td>
        </tr>
        <tr>
            <td rowspan="3">ROS 2</td>
            <td>Foxy</td>
            <td><a href="http://build.ros2.org/job/Fbin_uF64__rtabmap__ubuntu_focal_amd64__binary/"><img src="http://build.ros2.org/buildStatus/icon?job=Fbin_uF64__rtabmap__ubuntu_focal_amd64__binary" alt="Build Status"/></td>
        </tr>
        <tr>
            <td>Humble</td>
            <td><a href="http://build.ros2.org/job/Hbin_uJ64__rtabmap__ubuntu_jammy_amd64__binary/"><img src="http://build.ros2.org/buildStatus/icon?job=Hbin_uJ64__rtabmap__ubuntu_jammy_amd64__binary" alt="Build Status"/></td>
        </tr>
        <tr>
            <td>Rolling</td>
            <td><a href="http://build.ros2.org/job/Rbin_uJ64__rtabmap__ubuntu_jammy_amd64__binary/"><img src="http://build.ros2.org/buildStatus/icon?job=Rbin_uJ64__rtabmap__ubuntu_jammy_amd64__binary" alt="Build Status"/></td>
        </tr>
    </tbody>
</table>
 
---

### create image

```
git clone https://github.com/songwon31/slam_team2.git
cd slam_team2
sudo docker build --build-arg TARGETPLATFORM=linux/amd64 --no-cache --progress=tty --force-rm -f 1_dependency.dockerfile -t rtabmap_team2:deps .
sudo docker build --build-arg TARGETPLATFORM=linux/amd64 --no-cache --progress=tty --force-rm -f 2_rtabmap_with_ros.dockerfile -t rtabmap_team2:base .
```
- wsl2사용 시 test.dockerfile에서 # ENV DISPLAY=host.docker.internal:0.0 주석해제.

## 1. Linux 

### 1.1 with nvidia-gpu
#### install nvidia-docker2
```
sudo apt install -y nvidia-docker2
sudo systemctl daemon-reload
sudo systemctl restart docker
```

#### create container
```
export XAUTH=/tmp/.docker.xauth
touch $XAUTH
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -

docker run -it \
  --privileged \
  --env="DISPLAY=$DISPLAY" \
  --env="QT_X11_NO_MITSHM=1" \
  --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
  --env="XAUTHORITY=$XAUTH" \
  --volume="$XAUTH:$XAUTH" \
  --runtime=nvidia \
  --network host \
  -v ~/Documents/RTAB-Map:/root/Documents/RTAB-Map \
  rtabmap_team2:base
```

### 1.2 without gpu
#### create container
```
export XAUTH=/tmp/.docker.xauth
touch $XAUTH
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -

docker run -it \
  --privileged \
  --env="DISPLAY=$DISPLAY" \
  --env="QT_X11_NO_MITSHM=1" \
  --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
  --env="XAUTHORITY=$XAUTH" \
  --volume="$XAUTH:$XAUTH" \
  --network host \
  -v ~/Documents/RTAB-Map:/root/Documents/RTAB-Map \
  rtabmap_team2:base
```

## 2. WSL2

- test.dockerfile에서 # ENV DISPLAY=host.docker.internal:0.0 주석해제.

```
docker run -it \
  --privileged \
  --gpus all \
  --env="DISPLAY=$DISPLAY" \
  --network host \
  -v C:\path\to\mount\:/root/Documents/RTAB-Map \
  rtabmap_team2:base

```



### build rtabmap
```
source /ros_entrypoint.sh
cd rtabmap/build
mkdir ../../rtabmap_install
~/cmake -DWITH_OPENGV=ON -DCMAKE_INSTALL_PREFIX=../../rtabmap_install ..
make -j$(nproc)
sudo make install
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:../../rtabmap_install/lib
ldconfig
```
