FROM ros:melodic-perception

# Install build dependencies
RUN apt-get update && \
    apt-get install -y git wget software-properties-common ros-melodic-rtabmap-ros apt-utils && \
    apt-get remove -y ros-melodic-rtabmap && \
    apt-get clean && rm -rf /var/lib/apt/lists/

WORKDIR /root/

# ceres
RUN apt-get update && \
    apt-get install -y libceres-dev 

# GTSAM
RUN add-apt-repository ppa:borglab/gtsam-release-4.0 -y
RUN apt-get update && apt install libgtsam-dev libgtsam-unstable-dev -y && \
    apt-get clean && rm -rf /var/lib/apt/lists/

# MRPT
RUN add-apt-repository ppa:joseluisblancoc/mrpt-stable -y
RUN apt-get update && apt install libmrpt-poses-dev -y && \
    apt-get clean && rm -rf /var/lib/apt/lists/

# realsense2
RUN apt-get update && apt-get install -y ros-melodic-librealsense2 && \
    apt-get clean && rm -rf /var/lib/apt/lists/

# superpoint
RUN apt-get update && apt-get install zip -y && \
    wget https://download.pytorch.org/libtorch/cpu/libtorch-cxx11-abi-shared-with-deps-1.13.1%2Bcpu.zip && \
    unzip libtorch-cxx11-abi-shared-with-deps-1.13.1+cpu.zip && \
    rm libtorch-cxx11-abi-shared-with-deps-1.13.1+cpu.zip
# rtabmap/CmakeLists.txt 에서 find torh 부분 HINTS /root/libtorch/share/cmake/Torch 추가

ARG TARGETPLATFORM
ENV TARGETPLATFORM=${TARGETPLATFORM:-linux/amd64}
RUN echo "I am building for $TARGETPLATFORM"

# arm64
RUN if [ "$TARGETPLATFORM" = "linux/arm64" ]; then ln -s /usr/bin/cmake ~/cmake; fi

# cmake >=3.11 required for amd64 dependencies
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then apt update && apt install -y wget && apt-get clean && rm -rf /var/lib/apt/lists/ && \
    wget -nv https://github.com/Kitware/CMake/releases/download/v3.17.0/cmake-3.17.0-Linux-x86_64.tar.gz && \
    tar -xzf cmake-3.17.0-Linux-x86_64.tar.gz && \
    rm cmake-3.17.0-Linux-x86_64.tar.gz &&\
    ln -s ~/cmake-3.17.0-Linux-x86_64/bin/cmake ~/cmake; fi

#commit Aug 6 2020
RUN apt-get update && apt install wget && apt-get clean && rm -rf /var/lib/apt/lists/
RUN git clone https://github.com/laurentkneip/opengv.git && \
    cd opengv && \
    git checkout 91f4b19c73450833a40e463ad3648aae80b3a7f3 && \
    wget https://gist.githubusercontent.com/matlabbe/a412cf7c4627253874f81a00745a7fbb/raw/accc3acf465d1ffd0304a46b17741f62d4d354ef/opengv_disable_march_native.patch && \
    git apply opengv_disable_march_native.patch && \
    mkdir build && \
    cd build && \
    ~/cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make -j$(nproc) && \
    make install && \
    cd && \
    rm -r opengv

# opencv
RUN mkdir opencv && cd opencv && \
    git clone https://github.com/opencv/opencv.git && \
    git clone https://github.com/opencv/opencv_contrib.git && \
    mkdir build && cd build && \
    ~/cmake -DOPENCV_EXTRA_MODULES_PATH=../opencv_contrib/modules/ -DOPENCV_ENABLE_NONFREE=ON  ../opencv && \
    make -j$(nproc) && \
    make install

# g2o
RUN git clone https://github.com/RainerKuemmerle/g2o.git
RUN cd g2o && \
    git checkout 9b41a4e && \
    mkdir build && \
    cd build && \
    ~/cmake -DBUILD_LGPL_SHARED_LIBS=ON -DG2O_BUILD_APPS=OFF -DBUILD_WITH_MARCH_NATIVE=OFF -DG2O_BUILD_EXAMPLES=OFF -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release .. && \
    make -j$(nproc) && \
    make install

# libpointmatcher 
RUN git clone https://github.com/ethz-asl/libnabo.git
RUN cd libnabo && \
    git checkout 7e378f6765393462357b8b74d8dc8c5554542ae6 && \
    mkdir build && \
    cd build && \
    ~/cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make -j$(nproc) && \
    make install && \
    cd && \
    rm -r libnabo
RUN git clone https://github.com/ethz-asl/libpointmatcher.git
RUN cd libpointmatcher && \
    git checkout 00004bd41e44a1cf8de24ad87e4914760717cbcc && \
    mkdir build && \
    cd build && \
    ~/cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make -j$(nproc) && \
    make install && \
    cd && \
    rm -r libpointmatcher

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Copy current source code
RUN git clone https://github.com/songwon31/slam_team2.git

# Build RTAB-Map project
RUN source /ros_entrypoint.sh && \
    cd slam_team2/build && \
    mkdir ../../rtabmap_install && \
    ~/cmake -DWITH_OPENGV=ON -DWITH_G2O=ON -DCMAKE_INSTALL_PREFIX=../../rtabmap_install .. && \
    make -j$(nproc) && \
    make install && \
    export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:../../rtabmap_install/lib

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES \
    ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES \
    ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

# Will be used to read/store databases on host
RUN mkdir -p /root/Documents/RTAB-Map

# wsl
# ENV DISPLAY=host.docker.internal:0.0
# On Nvidia Jetpack, uncomment the following (https://github.com/introlab/rtabmap/issues/776):
# ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/aarch64-linux-gnu/tegra
