FROM ubuntu:14.04.5

# Prepare ubuntu
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN locale-gen en_GB en_GB.UTF-8
RUN apt-get install -y curl git man libfontconfig build-essential libkrb5-dev
RUN ln -sf /bin/bash /bin/sh

# Install supervisord
RUN apt-get install -y supervisor
RUN mkdir -p /var/log/supervisor
CMD /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
ONBUILD COPY ./docker/supervisor.conf /etc/supervisor/conf.d/

# Configure standard environment
WORKDIR /root/app

# Configure node
ENV NODE_ENV live

# Install NVM
RUN curl -L https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | HOME=/root bash

# Invalidate cache if .nvmrc changes
ONBUILD COPY .nvmrc /root/app/.nvmrc-temp

# Invalidate cache if .npmrc changes
ONBUILD COPY .npmrc /root/app/.npmrc

# Make nvm install node specified in .nvmrc
ONBUILD RUN source /root/.nvm/nvm.sh && \

  # HACK: Without this, sourcing of nvm.sh would fail.
  #       nvm.sh Would try to load the version .nvmrc that is not yet installed
  mv /root/app/.nvmrc-temp /root/app/.nvmrc && \

  # Install nodejs version specified in .nvmrc
  nvm install && \
  nvm alias default && \
  nvm use && \
  ln -sf $(which node) /usr/bin/node && \
  ln -sf $(which npm) /usr/bin/npm

# package-lock.json and package.json are used to bust the cache
ONBUILD COPY package.json /root/app/package.json
ONBUILD COPY package-lock.json /root/app/package-lock.json
ONBUILD RUN NODE_ENV=development npm install && \
  npm cache clean --force

# manifest.json is generated by Makefile, used by the status check
ONBUILD COPY ./ /root/app/

# display installed nvm packages, should not be cached if any files changed
ONBUILD RUN npm ll --depth 0 || true
