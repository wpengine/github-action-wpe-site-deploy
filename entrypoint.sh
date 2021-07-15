#!/bin/sh -l

set -e

: ${WPE_SSHG_KEY_PRIVATE?Required secret not set.}

#SSH Key Vars 
SSH_PATH="$HOME/.ssh"
KNOWN_HOSTS_PATH="$SSH_PATH/known_hosts"
WPE_SSHG_KEY_PRIVATE_PATH="$SSH_PATH/github_action"

echo $GITHUB_REF;
echo "refs/heads/$GH_DEVELOPMENT_BRANCH";

if [[ $GITHUB_REF =~ "$GH_PRODUCTON_BRANCH$" ]]; then
    echo "WPE_ENV_NAME=${{ env.WPE_PRODUCTION_ENV }}" >> $GITHUB_ENV;
    export WPE_ENV_NAME=${{ env.WPE_PRODUCTION_ENV }}
elif [[ $GITHUB_REF =~ "$GH_STAGING_BRANCH$" ]]; then
    echo "WPE_ENV_NAME=${{ env.WPE_STAGING_ENV }}" >> $GITHUB_ENV;
    export WPE_ENV_NAME=${{ env.WPE_STAGING_ENV }}
elif [[ $GITHUB_REF =~ "$GH_DEVELOPMENT_BRANCH$" ]]; then
    echo "WPE_ENV_NAME=${{ env.WPE_DEVELOPMENT_ENV }}" >> $GITHUB_ENV;
    export WPE_ENV_NAME=${{ env.WPE_DEVELOPMENT_ENV }}
else 
    echo "Branch name required" && exit 1;
fi

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

# Set up our user and path

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