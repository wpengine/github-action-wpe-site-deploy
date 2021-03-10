# GitHub Action for WP Engine Site Deployments

This GitHub Action can be used to deploy your WordPress repo/branch from Github to a WP Engine environment (Production / Stage / Dev) via the WP Engine SSH Gateway toolkit and a prefashioned rsync protocol. This can also be used to specifically deploy a single directory of your choice such as a theme or plugin directory. 

## Example GitHub Action workflow

1. Create a `.github/workflows/main.yml` file in your root of your WordPress project/repo, if one doesn't exist already.

2. Add the following to the `main.yml` file, replacing <YOUR INSTALL NAME> and the public and private key var names if they were anything other than what is below. Consult "Furthur Reading" on how to setup keys in repo Secrets. 

3. Git push your site repo. 

```
name: Deploy to WP Engine

on:  
  push:
    branches:
        - main

jobs:
  build:

    runs-on: ubuntu-latest
        
    steps: 
    - uses: actions/checkout@v2
    - name: SSH Deploy to WP Engine
      uses: wpengine/github-action-wpe-site-deploy@main
      env: 
          WPE_ENV_NAME: yoursitename 
          WPE_SSHG_KEY_PUBLIC: ${{ secrets.PUBLIC_KEY_NAME }} 
          WPE_SSHG_KEY_PRIVATE: ${{ secrets.PRIVATE_KEY_NAME }} 
          TPO_SRC_PATH: ""
          TPO_PATH: ""

          

```

## Environment Variables & Secrets

### Required

| Name | Type | Usage |
|-|-|-|
| `WPE_ENV_NAME` | Environment Variable | Insert the name of the WP Engine environment you want to deploy to. |
| `WPE_SSHG_KEY_PRIVATE` | Secret | Private SSH Key for the SSH Gateway and deployment. See below for SSH key usage. |
| `WPE_SSHG_KEY_PUBLIC` | Secret | Public SSH Key for the SSH Gateway and deployment. See below for SSH key usage. |

### Optional

| Name | Type | Usage |
|-|-|-|
| `TPO_SRC_PATH` | Optional path to specify a theme, plugin, or other directory source to deploy from. Ex. `"wp-content/themes/genesis-child/"` . Defaults to "." Dir. |
| `TPO_PATH` | Optional path to specify a theme, plugin, or other directory destination to deploy to. Ex. `"wp-content/themes/genesis-child/"` . Defaults to WordPress root directory.  |

### Further reading

* [Defining environment variables in GitHub Actions](https://developer.github.com/actions/creating-github-actions/accessing-the-runtime-environment/#environment-variables)
* [Storing secrets in GitHub repositories](https://developer.github.com/actions/managing-workflows/storing-secrets/)

## Setting up your SSH keys for repo

1. [Generate a new SSH key pair](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/) as a special deploy key between your Github Repo and WP Engine. The simplest method is to generate a key pair with a blank passphrase, which creates an unencrypted private key. 

2. Store your public and private keys in the GitHub repository of your website as new 'Secrets' (under your repository settings) using the names `PRIVATE_KEY_NAME` and `PUBLIC_KEY_NAME` respectively with the name in your specfic files. These can be customized, just remember to change the var in the yml file to call them correctly. 

3. Add the Public SSH key to your WP Engine SSH Gateway configuration. https://wpengine.com/support/ssh-gateway/#addsshkey
