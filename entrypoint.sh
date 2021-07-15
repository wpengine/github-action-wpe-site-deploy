#!/bin/sh -l

set -e

: ${WPE_ENV_NAME?Required environment name variable not set.}
: ${WPE_SSHG_KEY_PRIVATE?Required secret not set.}

#SSH Key Vars 
SSH_PATH="$HOME/.ssh"
KNOWN_HOSTS_PATH="$SSH_PATH/known_hosts"
WPE_SSHG_KEY_PRIVATE_PATH="$SSH_PATH/github_action"

#Deploy Vars
WPE_SSH_HOST="$WPE_ENV_NAME.ssh.wpengine.net"
if [ -n "$TPO_PATH" ]; then 
    DIR_PATH="$TPO_PATH"
else 
    DIR_PATH=""
fi

if [ -n "$TPO_SRC_PATH" ]; then
    SRC_PATH="$TPO_SRC_PATH"
else
    SRC_PATH="."
fi

declare -A ENVIRONMENTS_BRANCHES
ENVIRONMENTS_BRANCHES[$WPE_PRODUCTION_ENV]=$GH_PRODUCTION_BRANCH
ENVIRONMENTS_BRANCHES[$WPE_STAGING_ENV]=$GH_STAGING_BRANCH
ENVIRONMENTS_BRANCHES[$WPE_DEVELOPMENT_ENV]=$GH_DEVELOPMENT_BRANCH

echo $ENVIRONMENTS_BRANCHES

#      - name: Set variable (prod)
#        if: github.ref == "refs/heads/${{ env.GH_PRODUCTION_BRANCH }}"
#        run: |
#          echo "WPE_ENV_NAME=${{ env.WPE_PRODUCTION_ENV }}" >> $GITHUB_ENV
#      - name: Set variable (stage)
#        if: endsWith(github.ref, "/${{ env.GH_STAGING_BRANCH }}")
#        run: |
#          echo "WPE_ENV_NAME=${{ env.WPE_STAGING_ENV }}" >> $GITHUB_ENV
#      - name: Set variable (dev)
#        if: endsWith(github.ref, "/${{ env.GH_DEVELOPMENT_BRANCH }}")
#        run: |
#          echo "WPE_ENV_NAME=${{ env.WPE_DEVELOPMENT_ENV }}" >> $GITHUB_ENV

# Set up our 

WPE_SSH_USER="$WPE_ENV_NAME"@"$WPE_SSH_HOST"

WPE_DESTINATION="$WPE_SSH_USER":sites/"$WPE_ENV_NAME"/"$DIR_PATH"

# Setup our SSH Connection & use keys
mkdir "$SSH_PATH"
ssh-keyscan -t rsa "$WPE_SSH_HOST" >> "$KNOWN_HOSTS_PATH"

#Copy Secret Keys to container
echo "$WPE_SSHG_KEY_PRIVATE" > "$WPE_SSHG_KEY_PRIVATE_PATH"

#Set Key Perms 
chmod 700 "$SSH_PATH"
chmod 644 "$KNOWN_HOSTS_PATH"
chmod 600 "$WPE_SSHG_KEY_PRIVATE_PATH"

# Deploy via SSH
rsync --rsh="ssh -v -p 22 -i ${WPE_SSHG_KEY_PRIVATE_PATH} -o StrictHostKeyChecking=no" -a --out-format="%n"  --exclude=".*" $SRC_PATH "$WPE_DESTINATION"

# Clear cache 
ssh -v -p 22 -i ${WPE_SSHG_KEY_PRIVATE_PATH} -o StrictHostKeyChecking=no $WPE_SSH_USER "cd sites/${WPE_ENV_NAME} && wp page-cache flush"
echo "SUCCESS: Site has been deployed and cache has been flushed."