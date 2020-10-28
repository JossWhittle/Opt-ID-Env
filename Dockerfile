FROM ubuntu:focal

# Find latest packages
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update -y && apt-get install -y dialog apt-utils

# Install packages
RUN apt-get install -y build-essential git libopenmpi-dev openmpi-bin
RUN apt-get install -y python3 python3-pip 

# Register python3 as python (required for radia install which calls "python" blindly)
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 10
RUN update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 10

# Clean up apt to make image smaller
RUN apt-get autoremove -y --purge && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Install python packages
RUN pip3 install --upgrade mock pytest pytest-cov coveralls coverage
RUN pip3 install --upgrade numpy scipy 
RUN pip3 install --upgrade h5py pandas matplotlib
RUN pip3 install --upgrade mpi4py
RUN pip3 install --upgrade jax jaxlib

# Clean up pip to make image smaller
RUN find /usr/lib/python3.*/ -name 'tests' -exec rm -rf '{}' +

# Build radia (only need radia.so and radia.pyd on the the PYTHONPATH)
RUN mkdir /tmp/radia
RUN git clone https://github.com/ochubar/Radia.git /tmp/radia
RUN make -C /tmp/radia/cpp/gcc all
RUN make -C /tmp/radia/cpp/py
RUN mkdir -p /usr/local/radia && \
    cp /tmp/radia/env/radia_python/radia.so  /usr/local/radia/radia.so && \
    cp /tmp/radia/env/radia_python/radia.pyd /usr/local/radia/radia.pyd && \
    rm -rf /tmp/radia
ENV PYTHONPATH="/usr/local/radia:${PYTHONPATH}"
