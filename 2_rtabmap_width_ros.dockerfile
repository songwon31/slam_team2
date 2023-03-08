FROM rtabmap_team2:deps

WORKDIR /root/

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
    cp ../../rtabmap_install/lib/*.so /usr/lib && \
    ldconfig

RUN source /ros_entrypoint.sh && \
    mkdir -p catkin_ws/src && \
    cd catkin_ws/src && \
    catkin_init_workspace && \
    git clone https://github.com/introlab/rtabmap_ros.git && \
    git clone https://github.com/fizyr-forks/vision_opencv.git && \
    cd vision_opencv && \
    git checkout opencv4 && \
    cd ../.. && \
    catkin_make -j&(nproc)


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
