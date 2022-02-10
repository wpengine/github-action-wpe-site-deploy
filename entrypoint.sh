#!/bin/bash -l

set -e

: ${INPUT_WPE_SSHG_KEY_PRIVATE?Required secret not set.}

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
# elif [[ ${GITHUB_REP} =~ ${INPUT_NEW_BRANCH_NAME}$ ]]; then
#     export WPE_ENV_NAME=${INPUT_NEW_ENV_NAME};    
###

if [[ $GITHUB_REF =~ ${INPUT_PRD_BRANCH}$ ]]; then
    export WPE_ENV_NAME=$INPUT_PRD_ENV;
elif [[ $GITHUB_REF =~ ${INPUT_STG_BRANCH}$ ]]; then
    export WPE_ENV_NAME=$INPUT_STG_ENV;
elif [[ $GITHUB_REF =~ ${INPUT_DEV_BRANCH}$ ]]; then
    export WPE_ENV_NAME=$INPUT_DEV_ENV;    
else 
    echo "FAILURE: Branch name required." && exit 1;
fi

echo "Deploying $GITHUB_REF to $WPE_ENV_NAME..."

#Deploy Vars
WPE_SSH_HOST="$WPE_ENV_NAME.ssh.wpengine.net"
DIR_PATH="$INPUT_TPO_PATH"
SRC_PATH="$INPUT_TPO_SRC_PATH"
 
# Set up our user and path

WPE_SSH_USER="$WPE_ENV_NAME"@"$WPE_SSH_HOST"
WPE_DESTINATION=wpe_gha+"$WPE_SSH_USER":sites/"$WPE_ENV_NAME"/"$DIR_PATH"

# Setup our SSH Connection & use keys
mkdir "$SSH_PATH"
ssh-keyscan -t rsa "$WPE_SSH_HOST" >> "$KNOWN_HOSTS_PATH"

#Copy Secret Keys to container
echo "$INPUT_WPE_SSHG_KEY_PRIVATE" > "$WPE_SSHG_KEY_PRIVATE_PATH"
#Set Key Perms 
chmod 700 "$SSH_PATH"
chmod 644 "$KNOWN_HOSTS_PATH"
chmod 600 "$WPE_SSHG_KEY_PRIVATE_PATH"

echo "prepping file perms..."
find $SRC_PATH -type d -exec chmod -R 775 {} \;
find $SRC_PATH -type f -exec chmod -R 664 {} \;
echo "file perms set..."

# Lint before deploy
if [ "${INPUT_PHP_LINT^^}" == "TRUE" ]; then
    echo "Begin PHP Linting."
    for file in $(find $SRC_PATH/ -name "*.php"); do
        php -l $file
        status=$?
        if [[ $status -ne 0 ]]; then
            echo "FAILURE: Linting failed - $file :: $status" && exit 1
        fi
    done
    echo "PHP Lint Successful! No errors detected!"
else 
    echo "Skipping PHP Linting."
fi


# Deploy via SSH
# Exclude restricted paths from exclude.txt
rsync --rsh="ssh -v -p 22 -i ${WPE_SSHG_KEY_PRIVATE_PATH} -o StrictHostKeyChecking=no" $INPUT_FLAGS --exclude-from='/exclude.txt' $SRC_PATH "$WPE_DESTINATION"

# Post deploy clear cache 
if [ "${INPUT_CACHE_CLEAR^^}" == "TRUE" ]; then
    echo "Clearing WP Engine Cache..."
    ssh -v -p 22 -i ${WPE_SSHG_KEY_PRIVATE_PATH} -o StrictHostKeyChecking=no $WPE_SSH_USER "cd sites/${WPE_ENV_NAME} && wp page-cache flush"
    echo "SUCCESS: Site has been deployed and cache has been flushed."
else
    echo "Skipping Cache Clear."
fi