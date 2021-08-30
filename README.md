# GitHub Action for WP Engine Site Deployments

This GitHub Action can be used to deploy code from Github repo to a WP Engine environment of your choosing. Deploy a full site directory, or optionally a theme, plugin or other directory with the TPO options. Optionally lint your php pre-deployment. Post deploy, this action will automatically purge your WP Engine cache to ensure all changes are visible. 

V2.2 NOW AVAILABLE!

Note: v2.2 WILL REQUIRE an update to the main.yml configuration to enable optional flags. Replacing `env:` for `with:` to follow Github Action best practice and to utilize new options of the tool moving forward. This should allow our team to append new features of the tool with greater ease and no impact to customer configs moving forward. Thank you for your patience during our pre-release phase, all feedback welcome via issues or pull requests!

v2.2 includes optional `FLAGS` variable for users to customize their own rsync deploy protocol. This is completely optional and the toolkit will work without any `FLAGS` variable by relying on the flags historically built into the tool. 

## Example GitHub Action workflow

1. Create a `.github/workflows/main.yml` file in your root of your WordPress project/repo, if one doesn't exist already.

2. Add the following to the `main.yml` file, replacing values for `PRD_BRANCH`, `PRD_ENV` and `WPE_SSHG_KEY_PRIVATE` if they are anything other than what is below. Optionally, values for `STG_` and `DEV_` environments and branches can be specified. Consult ["Further Reading"](#further-reading) on how to setup keys in repo Secrets.

3. Git push your site repo. The action will do the rest 

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
      uses: wpengine/github-action-wpe-site-deploy@v2.2
      with:
      
      # Keys, lint & url options 
        WPE_SSHG_KEY_PRIVATE: ${{ secrets.WPE_SSHG_KEY_PRIVATE }} 
        PHP_LINT: TRUE
        FLAGS: -azvr --inplace --exclude=".*"
        CACHE_CLEAR: TRUE
        TPO_SRC_PATH: ""
        TPO_PATH: ""
      
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
| `FLAGS` | string | Set optional rsync flags such as `--delete`. This action defaults to a non-destructive deploy using the flags in the example above. |
| `CACHE_CLEAR` | bool | Optionally clear cache post deploy. This takes a few seconds. Default is TRUE. |
| `TPO_SRC_PATH` | string | Optional path to specify a theme, plugin, or other directory source to deploy from. Ex. `"wp-content/themes/genesis-child/"` . Defaults to "." Dir. |
| `TPO_PATH` | string | Optional path to specify a theme, plugin, or other directory destination to deploy to. Ex. `"wp-content/themes/genesis-child/"` . Defaults to WordPress root directory.  |

## Setting up your SSH keys for repo

1. [Generate a new SSH key pair](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/) as a special deploy key between your Github Repo and WP Engine. The simplest method is to generate a key pair with a blank passphrase, which creates an unencrypted private key. 

2. Store your private key in the GitHub repository of your website as new 'Secrets' (under your repository settings) using the names `WPE_SSHG_KEY_PRIVATE` with the name in your specfic files. These can be customized, just remember to change the var in the yml file to call them correctly. 

3. Add the Public SSH key to your WP Engine SSH Gateway configuration. https://wpengine.com/support/ssh-gateway/#addsshkey

### Further reading 

* [Defining environment variables in GitHub Actions](https://docs.github.com/en/actions/reference/environment-variables)
* [Storing secrets in GitHub repositories](https://docs.github.com/en/actions/reference/encrypted-secrets)
* As this script does not restrict files or directories that can be deployed, it is recommended to leverage one of [WP Engine's .gitignore tamplates.](https://wpengine.com/support/git/#Add_gitignore)
