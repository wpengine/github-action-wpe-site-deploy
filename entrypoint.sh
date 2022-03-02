#!/bin/bash -l

set -e

: ${INPUT_WPE_SSHG_KEY_PRIVATE?Required secret not set.}

#Alias logic for ENV names 
if [[ -n ${INPUT_WPE_ENV} ]]; then
    WPE_ENV_NAME="${INPUT_WPE_ENV}";
  elif [[ -n ${INPUT_PRD_ENV} ]]; then
    WPE_ENV_NAME="${INPUT_PRD_ENV}";
  elif [[ -n ${INPUT_STG_ENV} ]]; then
    WPE_ENV_NAME="${INPUT_STG_ENV}";
  elif [[ -n ${INPUT_DEV_ENV} ]]; then  
    WPE_ENV_NAME="${INPUT_DEV_ENV}";
  else echo "Failure: Missing environment variable..."  && exit 1;
fi

echo "Deploying your code to:"
echo ${WPE_ENV_NAME}


# Setup SSH Key Vars 
SSH_PATH="$HOME/.ssh"
KNOWN_HOSTS_PATH="$SSH_PATH/known_hosts"
WPE_SSHG_KEY_PRIVATE_PATH="$SSH_PATH/github_action"

# Deploy Vars
WPE_SSH_HOST="$WPE_ENV_NAME.ssh.wpengine.net"
DIR_PATH="$INPUT_REMOTE_PATH"
SRC_PATH="$INPUT_SRC_PATH"
 
# Set up our user and path

WPE_SSH_USER="$WPE_ENV_NAME"@"$WPE_SSH_HOST"
WPE_DESTINATION=wpe_gha+"$WPE_SSH_USER":sites/"$WPE_ENV_NAME"/"$DIR_PATH"

# Setup our SSH Connection & use keys
mkdir "$SSH_PATH"
ssh-keyscan -t rsa "$WPE_SSH_HOST" >> "$KNOWN_HOSTS_PATH"
cp "/config" $SSH_PATH/config

# Copy Secret Keys to container
echo "$INPUT_WPE_SSHG_KEY_PRIVATE" > "$WPE_SSHG_KEY_PRIVATE_PATH"
# Set Key Perms 
chmod 700 "$SSH_PATH"
chmod 644 "$KNOWN_HOSTS_PATH"
chmod 644 "$SSH_PATH/config"
chmod 600 "$WPE_SSHG_KEY_PRIVATE_PATH"

echo "prepping file perms..."
find $SRC_PATH -type d -exec chmod -R 775 {} \;
find $SRC_PATH -type f -exec chmod -R 664 {} \;
echo "file perms set..."

# pre deploy php lint
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
rsync --rsh="ssh -v -p 22 $INPUT_FLAGS --exclude-from='/exclude.txt' $SRC_PATH "$WPE_DESTINATION"

# post deploy script 
if [[ -n ${INPUT_SCRIPT} ]]; then 
    SCRIPT="&& sh ${INPUT_SCRIPT}"; 
  else 
    SCRIPT=""
fi 

# post deploy cache clear
if [ "${INPUT_CACHE_CLEAR^^}" == "TRUE" ]; then
    CACHE_CLEAR="&& wp page-cache flush"
  elif [ "${INPUT_CACHE_CLEAR^^}" == "FALSE" ]; then
      CACHE_CLEAR=""
  else echo "CACHE_CLEAR must be TRUE or FALSE only... Cache not cleared..."  && exit 1;
fi

if [[ -n ${SCRIPT} || -n ${CACHE_CLEAR} ]]; then 
    ssh -v -p 22 $WPE_SSH_USER "cd sites/${WPE_ENV_NAME} ${SCRIPT} ${CACHE_CLEAR}"
fi 

echo "SUCCESS: Your code has been deployed to WP Engine!"