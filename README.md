# GitHub Action for WP Engine Site Deployments

This GitHub Action may be used to deploy code from a Github repo to a WP Engine environment of your choosing. Deploy a full site directory, or optionally just a theme, plugin or other directory with the TPO options. Other options include performing a PHP Lint, custom rsync flags, or clearing cache. 

V2.3.5 NOW AVAILABLE! [View Changelog here.](https://github.com/wpengine/github-action-wpe-site-deploy/releases)

## Setup Instructions 

Follow along with the [video tutorial here!](https://wpengine-2.wistia.com/medias/crj1lp3qke)

1. **MAIN.YML SETUP**
* Copy the following `main.yml` to `.github/workflows/main.yml` in your root of your local WordPress project/repo, replacing values of `PRD_BRANCH`, `PRD_ENV` for the branch and WPE Environment name of your choice. Optional vars can be specified as well. Consult ["Environment Variable & Secrets"](#environment-variables--secrets) for more available options. 

2. **SSH PRIVATE KEY SETUP IN GITHUB**
* [Generate a new SSH key pair](https://wpengine.com/support/ssh-keys-for-shell-access/#Generate_New_SSH_Key) if you have not already done so. 

* Add the *SSH Private Key* to your [Repository Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository) or your [Organization Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-an-organization). Save the new secret "Name" as `WPE_SSHG_KEY_PRIVATE`. 

**NOTE:** If using a Github Organization, adding the SSH key to the Organization Secrets will allow all repos to reference the same SSH key for deploys using the method in the sample `main.yml`. The SSH Key also connects to all installs made available to its WP Engine User. One key can then effectively be used to deploy all projects to their respective sites on WP Engine. Less work. More deploys! 

3. **SSH PUBLIC KEY SETUP IN WP ENGINE**
* Add *SSH Public Key* to WP Engine SSH Gateway Key settings. [This Guide will show you how.](https://wpengine.com/support/ssh-gateway/#Add_SSH_Key) 

    **NOTE:** This Action DOES NOT utilize WP Engine GitPush or the GitPush SSH keys [found here.](https://wpengine.com/support/git/#Add_SSH_Key_to_User_Portal)

4. Git push your site Github repo. The action will do the rest! 

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
      uses: wpengine/github-action-wpe-site-deploy@v2.3.5
      with:
      
      # Deploy vars
        WPE_SSHG_KEY_PRIVATE: ${{ secrets.WPE_SSHG_KEY_PRIVATE }} 
      
      # Environment
        WPE_ENV: prodsitehere
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
      uses: wpengine/github-action-wpe-site-deploy@v2.3.5
      with:
      # Deploy vars 
        WPE_SSHG_KEY_PRIVATE: ${{ secrets.WPE_SSHG_KEY_PRIVATE }} 
        PHP_LINT: TRUE
        FLAGS: -azvr --inplace --delete --exclude=".*" --exclude-from=.deployignore
        CACHE_CLEAR: TRUE
        SRC_PATH: "wp-content/themes/genesis-child-theme/"
        REMOTE_PATH: "wp-content/themes/genesis-child-theme/"
      # Environment
        WPE_ENV: prodsitehere
```

## Environment Variables & Secrets

### Required

| Name | Type | Usage |
|-|-|-|
| `WPE_SSHG_KEY_PRIVATE` | secrets | Private SSH Key for the SSH Gateway and deployment. See below for SSH key usage. |

### Optional

| Name | Type | Usage |
|-|-|-|
| `WPE_ENV` | string | Insert the name of the WP Engine environment you want to deploy to. This also has an alias of `PRD_ENV`, `STG_ENV`, or `DEV_ENV` |
| `PHP_LINT` | bool | Set to TRUE to execute a php lint on your branch pre-deployment. Default is `FALSE`. |
| `FLAGS` | string | Set optional rsync flags such as `--delete` or `--exclude-from`. The example is excluding paths specified in a `.deployignore` file in the root of the repo. This action defaults to a non-destructive deploy using the flags in the example above. |
| `CACHE_CLEAR` | bool | Optionally clear cache post deploy. This takes a few seconds. Default is TRUE. |
| `SRC_PATH` | string | Optional path to specify a theme, plugin, or other directory source to deploy from. Ex. `"wp-content/themes/genesis-child-theme/"` . Defaults to "." Dir. |
| `REMOTE_PATH` | string | Optional path to specify a theme, plugin, or other directory destination to deploy to. Ex. `"wp-content/themes/genesis-child-theme/"` . Defaults to WordPress root directory.  |


### Further reading 

* [Defining environment variables in GitHub Actions](https://docs.github.com/en/actions/reference/environment-variables)
* [Storing secrets in GitHub repositories](https://docs.github.com/en/actions/reference/encrypted-secrets)
* As this script does not restrict files or directories that can be deployed, it is recommended to leverage one of [WP Engine's .gitignore templates.](https://wpengine.com/support/git/#Add_gitignore)
