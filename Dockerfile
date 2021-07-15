FROM cytopia/phplint:latest
LABEL "com.github.actions.name"="GitHub Action for WP Engine Site Deploy"
LABEL "com.github.actions.description"="An action to deploy your repository to WP Engine via the SSH Gateway"
LABEL "com.github.actions.icon"="upload-cloud"
LABEL "com.github.actions.color"="blue"
LABEL "repository"="http://github.com/wpengine/github-action-wpe-site-deploy"
LABEL "maintainer"="Alex Zuniga <alex.zuniga@wpengine.com>"
RUN apk add bash
ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
