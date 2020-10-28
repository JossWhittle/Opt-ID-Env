# Opt-ID-Env

[![Build Status](https://travis-ci.com/JossWhittle/Opt-ID-Env.svg?branch=main)](https://travis-ci.com/JossWhittle/Opt-ID-Env)

Uses Travis CI to build Docker images for the environments needed to the Opt-ID software developed by the Rosalind Franklin Institute and Diamond Light Source. https://github.com/DiamondLightSource/Opt-ID

Docker image pushed to `josswhittle/opt-id:env-v3` (see: https://hub.docker.com/r/josswhittle/opt-id/tags).

```
# On Travis CI this repo has three ENV vars configured:
DOCKER_USERNAME = "josswhittle"
DOCKER_PASSWORD = "secret"
DOCKER_REPO     = "opt-id:env-v3"

# Populate the Docker build cache on the Travis VM using the current version of the Docker image (if one exists)
docker pull $DOCKER_USERNAME/$DOCKER_REPO || true

# Build the Docker image from the Dockerfile in the root of this repo, respecting the cache if parts are unchanged
docker build --pull --cache-from $DOCKER_USERNAME/$DOCKER_REPO --tag $DOCKER_USERNAME/$DOCKER_REPO .

# Run the python unit tests in the test directory of this repo using the built Docker image
# Mounts the test directory of this repo to /tmp/tests directory within the Docker container
docker run --rm -it -v $(pwd)/tests/:/tmp/tests/ $DOCKER_USERNAME/$DOCKER_REPO python -B -m pytest -p no:cacheprovider /tmp/tests/ 

# If the tests pass, then deploy the Docker image to Dockerhub to replace the existing one
```
