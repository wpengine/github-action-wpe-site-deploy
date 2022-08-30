# Contributing

Thanks for your interest in contributing! There are several ways to get involved:

- Discuss open [issues](https://github.com/wpengine/github-action-wpe-site-deploy/issues).
- Submit [bugs](https://github.com/wpengine/github-action-wpe-site-deploy/issues/new?assignees=&labels=&template=bug_report.md&title=) and help us verify fixes as they are checked in.
- Open or participate in [discussions](https://github.com/wpengine/github-action-wpe-site-deploy/discussions) regarding feature requests.

### Managing the Dockerfile & Docker Image

The base of the `Dockerfile` is hosted as a Docker image on DockerHub. The image is originally built locally from `Dockerfiles/Dockerfile` and pushed up to DockerHub. The image will now automatically rebuild via automated docker build configurations, or it can be rebuilt manually via DockerHub or the original manual process.

The main `Dockerfile` at the project root imports the `wpengine/gha:base-stable` hosted image from DockerHub. Customizations to the image should be added below the base image for code that is updated more frequently, such as:
- entrypoint.sh
- exclude.txt

All other customizations that are updated less frequently, or managed by 3rd parties, should be added to the `base-stable` image. Rebuild and push the image to DockerHub to update the image.

#### Updating the Docker Image
The `base-stable` Docker Image will rarely need to be updated, however it may be necessary to update it manually* from time to time.

- Build the docker image locally:
`docker build --no-cache -t wpengine/gha:base-stable . `

- Push the image to DockerHub:
`docker push wpengine/gha:base-stable`

Once the hosted Docker image is updated, it will need to be imported (or updated) from the main project `Dockerfile` before all other customizations. If the Dockerhub tag name (image version) has changed, update the existing line in the project root `Dockerfile` to match the new tag name.
- Update the root Docker file for the project with the latest version of the Docker Image:tagname. i.e.:
`FROM wpengine/gha:base-stable`

_*TO DO: Process will be automated in the future._
