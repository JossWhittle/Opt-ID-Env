# Opt-ID-Env

![CI - Build Docker Image and Execute Tests](https://github.com/JossWhittle/Opt-ID-Env/workflows/CI%20-%20Build%20Docker%20Image%20and%20Execute%20Tests/badge.svg)

Uses Github Actions CI to build Docker images for the environments needed by the Opt-ID software developed by the Rosalind Franklin Institute and Diamond Light Source. https://github.com/DiamondLightSource/Opt-ID

Docker image pushed to `josswhittle/opt-id:env-v3` (see: https://hub.docker.com/r/josswhittle/opt-id/tags).

## Docker Image

Image is based on Ubuntu 20.04 Focal with the following installed

```
apt-get : build-essential git libopenmpi-dev openmpi-bin python3 python3-pip

pip     : mock pytest pytest-cov PyYAML coverage 
          numpy scipy h5py pandas matplotlib mpi4py jax jaxlib

manual  : Radia (https://github.com/ochubar/Radia)
```

If the tests pass, then deploy the Docker image to Dockerhub to replace the existing one

```
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
docker push $DOCKER_USERNAME/$DOCKER_REPO
```
