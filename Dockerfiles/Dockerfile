# Build and push a new image to Docker Hub when changes are made to this file.
# - Import the base Docker image hosted in DockerHub: https://hub.docker.com/repository/docker/wpengine/gha `FROM wpengine/gha:base-stable`
# - Customizations to the image should be added for code that is updated more frequently below the base image in github-action-wpe-site-deploy/Dockerfile.

FROM instrumentisto/rsync-ssh:alpine3.13-r4
LABEL "com.github.actions.name"="GitHub Action for WP Engine Site Deploy"
LABEL "com.github.actions.description"="An action to deploy your repository to WP Engine via the SSH Gateway"
LABEL "com.github.actions.icon"="upload-cloud"
LABEL "com.github.actions.color"="blue"
LABEL "repository"="http://github.com/wpengine/github-action-wpe-site-deploy"
LABEL "maintainer"="Alex Zuniga <alex.zuniga@wpengine.com>"
RUN apk add bash php
