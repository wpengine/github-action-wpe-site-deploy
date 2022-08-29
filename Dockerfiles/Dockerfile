# Build and push a new to Docker Hub when changes are made to this file.
# - Import the image to the main Dockerfile via DockerHub: https://hub.docker.com/repository/docker/wpengine/gha
# - Add any additional dockerfiles to the main Dockerfile after the import FROM wpengine/gha:v1

FROM instrumentisto/rsync-ssh:alpine3.13-r4
LABEL "com.github.actions.name"="GitHub Action for WP Engine Site Deploy"
LABEL "com.github.actions.description"="An action to deploy your repository to WP Engine via the SSH Gateway"
LABEL "com.github.actions.icon"="upload-cloud"
LABEL "com.github.actions.color"="blue"
LABEL "repository"="http://github.com/wpengine/github-action-wpe-site-deploy"
LABEL "maintainer"="Alex Zuniga <alex.zuniga@wpengine.com>"
RUN apk add bash php
