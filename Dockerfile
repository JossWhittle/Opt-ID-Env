# Copyright 2017 Diamond Light Source
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
# either express or implied. See the License for the specific
# language governing permissions and limitations under the License.

FROM ubuntu:focal

# Install packages and register python3 as python (required for radia install which calls "python" blindly)
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    apt-get update -y && apt-get install -y dialog apt-utils && \
    apt-get install -y build-essential git wget python3 python3-pip \
                       libfabric-dev libfabric1 libibverbs-dev libibverbs1 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3 10 && \
    update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 10 && \
    apt-get autoremove -y --purge && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Build specific OpenMPI with extensions
RUN mkdir -p /tmp/openmpi && \
    wget https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-4.0.0.tar.gz -P /tmp/openmpi && \
    tar xf /tmp/openmpi/openmpi-4.0.0.tar.gz -C /tmp/openmpi
WORKDIR /tmp/openmpi/openmpi-4.0.0/build
RUN ../configure --prefix=/usr/local \
                 --with-libfabric=/usr/ \
                 --with-verbs=/usr/ \
				 --with-verbs-libdir=/usr/lib/x86_64-linux-gnu/ \
                 --enable-mpi1-compatibility \
                 --disable-mpi-fortran && \
    make && \
    make install && \
    rm -rf /tmp/openmpi && \
    ldconfig
WORKDIR /

# Install python packages
RUN env MPICC=/usr/local/bin/mpicc pip3 install --no-cache-dir --upgrade \
        mock pytest pytest-cov PyYAML coveralls coverage \
        numpy scipy h5py pandas matplotlib mpi4py jax jaxlib && \
    rm -rf /tmp/* && \
    find /usr/lib/python3.*/ -name 'tests' -exec rm -rf '{}' +

# Build radia (only need radia.so on the the PYTHONPATH)
RUN mkdir -p /tmp/radia && \
    git clone https://github.com/ochubar/Radia.git /tmp/radia && \
    make -C /tmp/radia/cpp/gcc all && \
    make -C /tmp/radia/cpp/py && \
    mkdir -p /usr/local/radia && \
    cp /tmp/radia/env/radia_python/radia.so  /usr/local/radia/radia.so  && \
    rm -rf /tmp/radia
ENV PYTHONPATH="/usr/local/radia:${PYTHONPATH}"
