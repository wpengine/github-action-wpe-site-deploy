# Contributing

Thanks for your interest in contributing! There are several ways to get involved:

- Discuss open [issues](https://github.com/wpengine/github-action-wpe-site-deploy/issues).
- Submit [bugs](https://github.com/wpengine/github-action-wpe-site-deploy/issues/new?assignees=&labels=&template=bug_report.md&title=) and help us verify fixes as they are checked in.
- Open or participate in [discussions](https://github.com/wpengine/github-action-wpe-site-deploy/discussions) regarding feature requests.

### Managing the Dockerfile & Docker Image

The bulk of the Dockerfile is hosted as a Docker image on DockerHub. The image is originally built locally from a Dockerfile located in the Dockerfiles directory: `Dockerfiles/Dockerfile`. It is then also re-built automatically via automated docker build configurations.

Another Dockerfile at the project root imports the requested version (via Docker tag) from DockerHub and adds any customizations to the image as necessary.

#### Updating the Docker Image
The Docker image will rarely need to be updated. The Dockerfile is updated when a new version of the project is released.

- Build the docker image locally:
`docker build --no-cache -t wpengine/gha:v1 . `

- Push the image to DockerHub:
`docker push wpengine/gha:v1`

Once the hosted Docker image is updated, it will need to be manually imported and/or updated in the project root Dockerfile when the image version or tag changes.
- Update the root Docker file for the project with the latest version of the Docker Image. i.e.:
`FROM wpengine/gha:v1`

_*Process will be automated in the future._
