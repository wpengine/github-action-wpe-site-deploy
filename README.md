# GitHub Action for WP Engine Site Deployments

This GitHub Action may be used to deploy code from a GitHub repo to a WP Engine environment of your choosing. Deploy a full site directory or a subdirectory of your WordPress install. Other options include performing a PHP Lint, custom rsync flags, clearing cache and a executing a post-deploy script of your choosing. 

v3.0 AVAILABLE NOW! [View Changelog here.](https://github.com/wpengine/github-action-wpe-site-deploy/releases)



## Setup Instructions 
**TLDR;**  

(step 1 & 2) Connect GitHub and WP Engine, saving Private and Public SSH key to each respectively.  

(step 3) Setup local yml config to orchestrate deploy. 

1. **SSH PRIVATE KEY SETUP IN GITHUB**
* [Generate a new SSH key pair](https://wpengine.com/support/ssh-keys-for-shell-access/#Generate_New_SSH_Key) if you have not already done so. Please note that this SSH Key needs to be *passwordless*.

* Add the *SSH Private Key* to your [Repository Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository) or your [Organization Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-an-organization). Save the new secret "Name" as `WPE_SSHG_KEY_PRIVATE`. 

**NOTE:** If using a GitHub Organization, adding the SSH key to the [Organization Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-an-organization) will allow all repos to reference the same SSH key for deploys using the method in the sample `main.yml`. The SSH Key also connects to all installs made available to its WP Engine User. One key can then effectively be used to deploy all projects to their respective sites on WP Engine. Less work. More deploys! 

2. **SSH PUBLIC KEY SETUP IN WP ENGINE**

* Add *SSH Public Key* to WP Engine SSH Gateway Key settings. [This Guide will show you how.](https://wpengine.com/support/ssh-gateway/#Add_SSH_Key) 

**NOTE:** This Action DOES NOT utilize WP Engine GitPush or the GitPush SSH keys [found here.](https://wpengine.com/support/git/#Add_SSH_Key_to_User_Portal)
    
3. **YML SETUP**

* Create `.github/workflows/main.yml` directory and file locally. 
Copy and paste the configuration from below, replacing the value under `branches:` and the value for `WPE_ENV:`.

* To deploy from another branch, simply create another yml file locally for that branch, such as `.github/workflows/stage.yml` and replace the values for `branches:` and  `WPE_ENV:` for that workflow. 

This provides the ability to perform a different workflow for different branches/environments. Consult ["Environment Variable & Secrets"](#environment-variables--secrets) for more available options. 

4. Git push your site GitHub repo. The action will do the rest! 

View your actions progress and logs by navigating to the "Actions" tab in your repo. 

## Example GitHub Action workflow

### Simple main.yml:

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
    - name: GitHub Action Deploy to WP Engine
      uses: wpengine/github-action-wpe-site-deploy@v3.0
      with:
        WPE_SSHG_KEY_PRIVATE: ${{ secrets.WPE_SSHG_KEY_PRIVATE }} 
        WPE_ENV: <your_install_name_here>
```

### Extended main.yml

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
    - name: GitHub Action Deploy to WP Engine
      uses: wpengine/github-action-wpe-site-deploy@v3.0
      with:
      # Deploy vars 
        WPE_SSHG_KEY_PRIVATE: ${{ secrets.WPE_SSHG_KEY_PRIVATE }} 
        WPE_ENV: <your_install_name_here>
        # Deploy Options
        SRC_PATH: "wp-content/themes/genesis-child-theme/"
        REMOTE_PATH: "wp-content/themes/genesis-child-theme/"
        PHP_LINT: TRUE
        FLAGS: -azvr --inplace --delete --exclude=".*" --exclude-from=ignorefile.txt
        SCRIPT: "path/yourscript.sh"
        CACHE_CLEAR: TRUE
```

## Environment Variables & Secrets

### Required

| Name | Type | Usage |
|-|-|-|
| `WPE_SSHG_KEY_PRIVATE` | secrets | Private SSH Key for the SSH Gateway and deployment. See below for SSH key usage. |

### Deploy Options

| Name | Type | Usage |
|-|-|-|
| `WPE_ENV` | string | Insert the name of the WP Engine environment you want to deploy to. This also has an alias of `PRD_ENV`, `STG_ENV`, or `DEV_ENV` for multistep workflows. |
| `SRC_PATH` | string | Optional path to specify a directory within the repo to deploy from. Ex. `"wp-content/themes/genesis-child-theme/"`. Defaults to root of repo filesystem as source. |
| `REMOTE_PATH` | string | Optional path to specify a directory destination to deploy to. Ex. `"wp-content/themes/genesis-child-theme/"` . Defaults to WordPress root directory on WP Engine.  |
| `PHP_LINT` | bool | Set to TRUE to execute a php lint on your branch pre-deployment. Default is `FALSE`. |
| `FLAGS` | string | Set optional rsync flags such as `--delete` or `--exclude-from`. The example is excluding paths specified in a `.deployignore` file in the root of the repo. This action defaults to a non-destructive deploy using the flags in the example above. |
| `SCRIPT` | string | Remote bash file to execute post-deploy. This can include WP_CLI commands for example. Path is relative to the WP root and file executes on remote. This file can be included in your repo, or be a persistent file that lives on your server.  |
| `CACHE_CLEAR` | bool | Optionally clear cache post deploy. This takes a few seconds. Default is TRUE. |


### Further reading 

* [Defining environment variables in GitHub Actions](https://docs.github.com/en/actions/reference/environment-variables)
* [Storing secrets in GitHub repositories](https://docs.github.com/en/actions/reference/encrypted-secrets)
* It is recommended to leverage one of [WP Engine's .gitignore templates.](https://wpengine.com/support/git/#Add_gitignore)
* This action excludes several files and directories from the deploy by default. See the [exclude.txt](https://github.com/wpengine/github-action-wpe-site-deploy/blob/main/exclude.txt) for reference.  