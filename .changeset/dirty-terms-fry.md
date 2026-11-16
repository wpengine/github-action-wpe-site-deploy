---
"@wpengine/github-action-wpe-site-deploy": major
---

Bump wpengine/site-deploy image version to [2.0.0](https://github.com/wpengine/site-deploy/releases/tag/v2.0.0)
  - Removes the `PHP_LINT` option and drops PHP from the image. The action no longer runs `php -l` before deploying, and `php-cli` is no longer installed. Setting `PHP_LINT` has no effect. To keep linting PHP files, run it as a separate step in your workflow before the deploy.
  - Switches base image from Alpine 3.24 to Ubuntu 26.04 LTS. Tool versions change as follows. Check any custom rsync FLAGS usage against them:
      - rsync 3.5.2 (protocol 33) -> 3.4.1 (protocol 32). This is a downgrade, so options added in rsync 3.5.x will no longer work.
      - OpenSSH 10.3p1 -> 10.2p1
      - bash 5.3.9 (unchanged)
