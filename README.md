# GitHub Action for WP Engine Site Deployments

This GitHub Action may be used to deploy code from Github repo to a WP Engine environment of your choosing. Deploy a full site directory, or optionally a theme, plugin or other directory with the TPO options. Optionally lint your php pre-deployment. Post deploy, this action will automatically purge your WP Engine cache to ensure all changes are visible. 

V2.3.1 NOW AVAILABLE!

Changelog: 
v.2.3.1 Restricted paths are excluded from the rsync deploy such as `wp-config.php` as well as platform specific files that customers do not have permissions to edit. No action required. This should enhance expected behavior of the toolkit for users. Inspect `exclude.txt` for reference. 

v2.3 `CACHE_CLEAR` has been added as an option to the toolkit. Default is `TRUE` but users can disable by setting to `FALSE`. This may decrease the execution time of deploys. All planned options are now built into the toolkit. All feedback welcome via issues or pull requests! 

v2.2 includes optional `FLAGS` variable for users to customize their own rsync deploy protocol. This is completely optional and the toolkit will work without any `FLAGS` variable by relying on the flags historically built into the tool. 

NOTE: v2.2 WILL REQUIRE an update to the main.yml configuration to enable optional flags if you are using a previous version. Replacing `env:` for `with:` to follow Github Action best practice and to utilize new options of the tool moving forward. 


## SSH Gateway Key setup 

1. Copy the following `main.yml` to `.github/workflows/main.yml` in your root of your local WordPress project/repo, replacing values of `PRD_BRANCH`, `PRD_ENV` for the branch and WPE Environment name of your choice. Optional vars can be specified as well. Consult ["Environment Variable & Secrets"](#environment-variables--secrets) for more available options. 

2. [Generate a new SSH key pair](https://wpengine.com/support/ssh-keys-for-shell-access/#Generate_New_SSH_Key) if you have not already done so. Add the *SSH Private Key* to your Github repo settings. 

    **Repo > Settings > Secrets > Actions Secrets > New Repository Secrets** 

     Save the new secret "Name" as `WPE_SSHG_KEY_PRIVATE`. [More reading available here for Repo Secrets](https://docs.github.com/en/actions/reference/encrypted-secrets)

3. Add *SSH Public Key* to WP Engine SSH Gateway Key settings. [This Guide will show you how.](https://wpengine.com/support/ssh-gateway/#Add_SSH_Key) 

    **NOTE:** This Action DOES NOT utilize WP Engine GitPush or the GitPush SSH keys [found here](https://wpengine.com/support/git/#Add_SSH_Key_to_User_Portal)

4. Git push your site Github repo. The action will do the rest! 

View your actions progress and logs by navigating to the "Actions" tab in your repo. 

## Example GitHub Action workflow

### Simple main.yml:

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
      uses: wpengine/github-action-wpe-site-deploy@v2.3.1
      with:
      
      # Deploy vars
        WPE_SSHG_KEY_PRIVATE: ${{ secrets.WPE_SSHG_KEY_PRIVATE }} 
      
      # Branches & Environments 
        PRD_BRANCH: main
        PRD_ENV: prodsitehere
```

### Extended main.yml

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
      uses: wpengine/github-action-wpe-site-deploy@v2.3.1
      with:
      
      # Deploy vars 
        WPE_SSHG_KEY_PRIVATE: ${{ secrets.WPE_SSHG_KEY_PRIVATE }} 
        PHP_LINT: TRUE
        FLAGS: -azvr --inplace --delete --exclude=".*" --exclude-from=.deployignore
        CACHE_CLEAR: TRUE
        TPO_SRC_PATH: "wp-content/themes/genesis-child-theme/"
        TPO_PATH: "wp-content/themes/genesis-child-theme/"
      
      # Branches & Environments 
        PRD_BRANCH: main
        PRD_ENV: prodsitehere
        
        STG_BRANCH: feature/stage
        STG_ENV: stagesitehere
        
        DEV_BRANCH: feature/dev
        DEV_ENV: devsitehere
```

## Environment Variables & Secrets

### Required

| Name | Type | Usage |
|-|-|-|
| `PRD_BRANCH` | string | Insert the name of the Github branch you would like to deploy from, example; main. |
| `PRD_ENV` | string | Insert the name of the WP Engine environment you want to deploy to. |
| `WPE_SSHG_KEY_PRIVATE` | secrets | Private SSH Key for the SSH Gateway and deployment. See below for SSH key usage. |

### Optional

| Name | Type | Usage |
|-|-|-|
| `STG_BRANCH` | string | Insert the name of a staging Github branch you would like to deploy from. Note: exclude leading / from branch names.|
| `STG_ENV` | string | Insert the name of the WP Engine Stage environment you want to deploy to. |
| `DEV_BRANCH` | string | Insert the name of a development Github branch you would like to deploy from. Note: exclude leading / in branch names.|
| `DEV_ENV` | string | Insert the name of the WP Engine Dev environment you want to deploy to. |
| `PHP_LINT` | bool | Set to TRUE to execute a php lint on your branch pre-deployment. Set to FALSE to bypass lint. |
| `FLAGS` | string | Set optional rsync flags such as `--delete` or `--exclude-from`. The example is excluding paths specified in a `.deployignore` file in the root of the repo. This action defaults to a non-destructive deploy using the flags in the example above. |
| `CACHE_CLEAR` | bool | Optionally clear cache post deploy. This takes a few seconds. Default is TRUE. |
| `TPO_SRC_PATH` | string | Optional path to specify a theme, plugin, or other directory source to deploy from. Ex. `"wp-content/themes/genesis-child-theme/"` . Defaults to "." Dir. |
| `TPO_PATH` | string | Optional path to specify a theme, plugin, or other directory destination to deploy to. Ex. `"wp-content/themes/genesis-child-theme/"` . Defaults to WordPress root directory.  |


### Further reading 

* [Defining environment variables in GitHub Actions](https://docs.github.com/en/actions/reference/environment-variables)
* [Storing secrets in GitHub repositories](https://docs.github.com/en/actions/reference/encrypted-secrets)
* As this script does not restrict files or directories that can be deployed, it is recommended to leverage one of [WP Engine's .gitignore templates.](https://wpengine.com/support/git/#Add_gitignore)
