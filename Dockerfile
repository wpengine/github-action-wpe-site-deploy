FROM debian:9.7-slim

LABEL "com.github.actions.name"="GitHub Action for WP Engine SSH Gateway Deployment"
LABEL "com.github.actions.description"="An action to deploy your repository to WP Engine via the SSH Gateway"
LABEL "com.github.actions.icon"="chevrons-up"
LABEL "com.github.actions.color"="blue"

LABEL "repository"="http://github.com/boweidev/github-action-wpengine-ssh-deploy"
LABEL "maintainer"="Alex Zuniga <alex.zuniga@wpengine.com>"
RUN apt-get update && apt-get install -y openssh-server rsync
ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
