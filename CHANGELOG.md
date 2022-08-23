# @wpengine/github-action-wpe-site-deploy

## 3.1.1

### Patch Changes

- 0da65a6: Prevent plugin and theme conflicts from adversely affecting cache clear

## 3.1.0

### Minor Changes

- 559547c: Copy post-deploy `SCRIPT` to the remote if it exists in the repo but not on the remote. This allows for storing script files outside of `SRC_PATH`. [#12](https://github.com/wpengine/github-action-wpe-site-deploy/pull/12)

### Patch Changes

- 559547c: Fix action failures caused by attempts to rsync wpe-cache-plugin [#8](https://github.com/wpengine/github-action-wpe-site-deploy/pull/8)
