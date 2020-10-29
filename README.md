# Opt-ID-Env

[![Build Status](https://travis-ci.com/JossWhittle/Opt-ID-Env.svg?branch=main)](https://travis-ci.com/JossWhittle/Opt-ID-Env) [![https://www.singularity-hub.org/static/img/hosted-singularity--hub-%23e32929.svg](https://www.singularity-hub.org/static/img/hosted-singularity--hub-%23e32929.svg)](https://singularity-hub.org/collections/4925)

Uses Travis CI to build Docker images for the environments needed by the Opt-ID software developed by the Rosalind Franklin Institute and Diamond Light Source. https://github.com/DiamondLightSource/Opt-ID

Docker image pushed to `josswhittle/opt-id:env-v3` (see: https://hub.docker.com/r/josswhittle/opt-id/tags).

## Docker Image

Image is based on Ubuntu 20.04 Focal with the following installed

```
apt-get : build-essential git libopenmpi-dev openmpi-bin python3 python3-pip

pip     : mock pytest pytest-cov PyYAML coveralls coverage 
          numpy scipy h5py pandas matplotlib mpi4py jax jaxlib

manual  : Radia (https://github.com/ochubar/Radia)
```

## Travis CI Script

On Travis CI this repo has three ENV vars configured

``` 
DOCKER_USERNAME = "josswhittle"
DOCKER_PASSWORD = "secret"
DOCKER_REPO     = "opt-id:env-v3"
```

Populate the Docker build cache on the Travis VM using the current version of the Docker image (if one exists)

```
docker pull $DOCKER_USERNAME/$DOCKER_REPO || true
```

Build the Docker image from the Dockerfile in the root of this repo, respecting the cache if parts are unchanged

```
docker build --pull --cache-from $DOCKER_USERNAME/$DOCKER_REPO --tag $DOCKER_USERNAME/$DOCKER_REPO .
```

Start a container running the image that will keep running until we stop it...

  - `-itd` 
 	
 	Run the container in interactive mode, and detached so that it keeps running after this line.

  - `--name env` 
 	
 	We can refer to this running container by the name "env".

  - `--env-file <(env | grep TRAVIS)`
	
	Grab all environment varaibles from the host starting with "TRAVIS" and forward them into the container to allow coveralls to report properly.

  - `-v $(pwd):/tmp/repo/`
	
	Mount the current directory on the host (git repo root) to the directory /tmp/repo/ in the container.
 
  - `-w /tmp/repo/`
 	
 	Set the current working directory inside the container to the root of the git repo.

  - `$DOCKER_USERNAME/$DOCKER_REPO`
	
	The docker image to run.
```
docker run -itd --name env --env-file <(env | grep TRAVIS) -v $(pwd):/tmp/repo/ -w /tmp/repo/ $DOCKER_USERNAME/$DOCKER_REPO 
```

Run the python unit tests on the git repo

```
docker exec env python -m pytest tests/
```

Kill the container

```
docker stop env
```

If the tests pass, then deploy the Docker image to Dockerhub to replace the existing one

```
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
docker push $DOCKER_USERNAME/$DOCKER_REPO
```
