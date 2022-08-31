# Development

## Getting Started

Before you get started, we recommend installing [Node Version Manager](https://github.com/nvm-sh/nvm#installing-and-updating) to help manage `node` and `npm` versions. Next, from your local copy of the action run `nvm use` and `npm install`. You're ready to start coding!

## Git Workflows

We use the [feature branch workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/feature-branch-workflow). The workflow for a typical code change looks like this:

1. Create a new branch for the feature.
2. Make changes to the code.
3. Use `npx changeset` to create a changeset describing the change to users.
4. Commit your changes.
5. Open a pull request to the `main` branch.
6. Once all checks are passing and the PR is approved, Squash and Merge into the `main` branch.

## Creating a release

We use [Changesets](https://github.com/changesets/changesets) to automate versioning and releasing. When you are ready to release, the first step is to create the new version.

1. Go to pull requests and view the "Version Action" PR.
2. Review the PR:
    - [ ] Changelog entries were created.
    - [ ] Version number in package.json was bumped.
    - [ ] All `.changeset/*.md` files were removed.
3. Approve, then "Squash and merge" the PR into `main`.

Merging the versioning PR will run a workflow that creates or updates all necessary tags. It will also create a new release in GitHub.

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