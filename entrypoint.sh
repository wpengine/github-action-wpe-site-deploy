#!/bin/bash -l

set -e

: ${WPE_SSHG_KEY_PRIVATE?Required secret not set.}

#SSH Key Vars 
SSH_PATH="$HOME/.ssh"
KNOWN_HOSTS_PATH="$SSH_PATH/known_hosts"
WPE_SSHG_KEY_PRIVATE_PATH="$SSH_PATH/github_action"

###
# If you'd like to expand the environments, 
# Just copy/paste an elif line and the following export
# Then adjust variables to match the new ones you added in main.yml
#
# Example:
#
# elif [[ ${GITHUB_REP} =~ ${NEW_BRANCH_NAME}$ ]]; then
#     export WPE_ENV_NAME=${NEW_ENV_NAME};    
###

if [[ $GITHUB_REF =~ ${PRD_BRANCH}$ ]]; then
    export WPE_ENV_NAME=$PRD_ENV;
elif [[ $GITHUB_REF =~ ${STG_BRANCH}$ ]]; then
    export WPE_ENV_NAME=$STG_ENV;
elif [[ $GITHUB_REF =~ ${DEV_BRANCH}$ ]]; then
    export WPE_ENV_NAME=$DEV_ENV;    
else 
    echo "FAILURE: Branch name required." && exit 1;
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

FLAGS="$INPUT_FLAGS"
 
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

# Lint before deploy
if [ "${PHP_LINT^^}" == "TRUE" ]; then
    echo "Begin PHP Linting."
    for file in $(find $SRC_PATH/ -name "*.php"); do
        php -l $file
        status=$?
        if [[ $status -ne 0 ]]; then
            echo "FAILURE: Linting failed - $file :: $status" && exit 1
        fi
    done
    echo "End PHP Linting."
else 
    echo "Skipping PHP Linting."
fi

# Deploy via SSH
rsync --rsh="ssh -v -p 22 -i ${WPE_SSHG_KEY_PRIVATE_PATH} -o StrictHostKeyChecking=no" $FLAGS $SRC_PATH "$WPE_DESTINATION"

# Clear cache 
ssh -v -p 22 -i ${WPE_SSHG_KEY_PRIVATE_PATH} -o StrictHostKeyChecking=no $WPE_SSH_USER "cd sites/${WPE_ENV_NAME} && wp page-cache flush"
echo "SUCCESS: Site has been deployed and cache has been flushed."
echo ${FLAGS}
