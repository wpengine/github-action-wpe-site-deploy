# @wpengine/github-action-wpe-site-deploy

## 3.2.6

### Patch Changes

- 0a8b985: Bump wpengine/site-deploy image version 1.0.4

## 3.2.5

### Patch Changes

- 24a71db: Update wpengine/site-deploy image to 1.0.3

## 3.2.4

### Patch Changes

- 34b3009: Update link to exclude.txt
- 1a754af: Bump @changesets/cli > 2.26.2 (resolves semver vulnerability)
- 4e010b0: Update wpengine/site-deploy image to 1.0.2

## 3.2.3

### Patch Changes

- 2bc933a: Update wpengine/site-deploy image to 1.0.1

## 3.2.2

### Patch Changes

- 42002e5: Fixes an issue in v3.2.1 where the action may fail to resolve the public Docker image

## 3.2.1

### Patch Changes

- cecc467: [CICD-217] Replace split image with site-deploy combined image

## 3.2.0

### Minor Changes

- 24c8aaf: Add CDN cache clearing ability to the CACHE_CLEAR flag.

### Patch Changes

- 7301b87: Improve performance by utilizing pre-built Docker Image.

## 3.1.1

### Patch Changes

- 0da65a6: Prevent plugin and theme conflicts from adversely affecting cache clear

## 3.1.0

### Minor Changes

- 559547c: Copy post-deploy `SCRIPT` to the remote if it exists in the repo but not on the remote. This allows for storing script files outside of `SRC_PATH`. [#12](https://github.com/wpengine/github-action-wpe-site-deploy/pull/12)

### Patch Changes

- 559547c: Fix action failures caused by attempts to rsync wpe-cache-plugin [#8](https://github.com/wpengine/github-action-wpe-site-deploy/pull/8)
