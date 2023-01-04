# @wpengine/github-action-wpe-site-deploy

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
