# docker-nvm-npmrc

Basic image to build docker containers

## How to update it in quay.io

- docker login -u=DOCKER_USERNAME -p=DOCKER_PASSWORD quay.io
- docker build --tag docker-nvm-npmrc:<tag> .
- docker images | grep docker-nvm-npmrc
- docker commit <image_id> quay.io/username/reponame
- docker push quay.io/username/reponame:tag

Or even easier...configure a trigger on quay.io so the docker container builds on every push
