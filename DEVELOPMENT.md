# Development

## Getting Started

1. Clone the repository
2. Run `npm install`
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

Merging the versioning PR will run a workflow that creates or updates all necessary tags. The next step is to create a release in GitHub. This may be automated in the future, but for now the process is:

1. In GitHub, visit "Releases -> Draft new release"
2. In the "Choose a tag" dropdown, choose the tag you want to release. This is usually the most recently created patch tag (`v{MAJOR}.{MINOR}.{PATCH}`). Major/minor tags (i.e `v3` and `v3.0`) are only present to allow users to opt into automatic patch or minor version updates and should not be associated with a GitHub release.
3. Leave the target branch set to `main`.
4. Give the release a title. Typically, this will be identical to the release's tag name.
5. Copy the [CHANGLELOG.md](./CHANGELOG.md) entry for this release into the release body.
6. Click "Publish Release".
