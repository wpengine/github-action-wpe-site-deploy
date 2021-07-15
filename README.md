# GitHub Action for WP Engine Site Deployments

This GitHub Action can be used to deploy your WordPress repo/branch from Github to a WP Engine environment (Production / Stage / Dev) via the WP Engine SSH Gateway toolkit and a prefashioned rsync protocol. Deploy a theme, plugin or other directory with the TPO options. Post deploy, this action will automatically purge your WP Engine cache to ensure all changes are visible. 

## Example GitHub Action workflow

1. Create a `.github/workflows/main.yml` file in your root of your WordPress project/repo, if one doesn't exist already.

2. Add the following to the `main.yml` file, replacing WPE_PRODUCTION_ENV, WPE_STAGING_ENV, WPE_DEVELOPMENT_ENV and the public and private key var names and branches if they were anything other than what is below. Consult "Furthur Reading" on how to setup keys in repo Secrets.

3. Git push your site repo. 

```
name: Deploy to WP Engine
on:
  push:

jobs:
  build:
    runs-on: ubuntu-latest  
    steps: 
    - uses: actions/checkout@v2
    - name: GitHub Action Deploy to WP Engine
      uses: wpengine/github-action-wpe-site-deploy@feature/hackathon
      env:
      
      # Keys, lint & url options 
        WPE_SSHG_KEY_PRIVATE: ${{ secrets.WPE_SSHG_KEY_PRIVATE }} 
        PHP_LINT: TRUE
        TPO_SRC_PATH: ""
        TPO_PATH: ""
      
      # Branches & Environments 
        PRD_BRANCH: main
        PRD_ENV: prodsitehere
        
        STG_BRANCH: stage
        STG_ENV: stagesitehere
        
        DEV_BRANCH: dev
        DEV_ENV: devsitehere
```

## Environment Variables & Secrets

### Required

| Name | Type | Usage |
|-|-|-|
| `PRD_BRANCH` | Branch Variable | Insert the name of the Github branch you would like to deploy from, example; main. |
| `PRD_ENV` | Environment Variable | Insert the name of the WP Engine environment you want to deploy to. |
| `WPE_SSHG_KEY_PRIVATE` | Secret | Private SSH Key for the SSH Gateway and deployment. See below for SSH key usage. |



### Optional

| Name | Type | Usage |
|-|-|-|
| `STG_BRANCH` | Branch Variable | Insert the name of a staging Github branch you would like to deploy from. |
| `STG_ENV` | Environment Variable | Insert the name of the WP Engine Stage environment you want to deploy to. |
| `DEV_BRANCH` | Branch Variable | Insert the name of a development Github branch you would like to deploy from. |
| `DEV_ENV` | Environment Variable | Insert the name of the WP Engine Dev environment you want to deploy to. |
| `PHP_LINT` | Bool | Set to TRUE to execute a php lint on your branch pre-deployment. Set to FALSE to bypass lint. |
| `TPO_SRC_PATH` | Optional path to specify a theme, plugin, or other directory source to deploy from. Ex. `"wp-content/themes/genesis-child/"` . Defaults to "." Dir. |
| `TPO_PATH` | Optional path to specify a theme, plugin, or other directory destination to deploy to. Ex. `"wp-content/themes/genesis-child/"` . Defaults to WordPress root directory.  |

### Further reading

* [Defining environment variables in GitHub Actions](https://developer.github.com/actions/creating-github-actions/accessing-the-runtime-environment/#environment-variables)
* [Storing secrets in GitHub repositories](https://developer.github.com/actions/managing-workflows/storing-secrets/)
* As this script does not restrict files or directories that can be deployed, it is recommended to leverage one of [WP Engine's .gitignore tamplates.](https://wpengine.com/support/git/#Add_gitignore)

## Setting up your SSH keys for repo

1. [Generate a new SSH key pair](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/) as a special deploy key between your Github Repo and WP Engine. The simplest method is to generate a key pair with a blank passphrase, which creates an unencrypted private key. 

2. Store your public and private keys in the GitHub repository of your website as new 'Secrets' (under your repository settings) using the names `PRIVATE_KEY_NAME` and `PUBLIC_KEY_NAME` respectively with the name in your specfic files. These can be customized, just remember to change the var in the yml file to call them correctly. 

3. Add the Public SSH key to your WP Engine SSH Gateway configuration. https://wpengine.com/support/ssh-gateway/#addsshkey