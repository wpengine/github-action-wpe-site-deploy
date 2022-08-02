#!/bin/bash -l

set -e

: "${INPUT_WPE_SSHG_KEY_PRIVATE?Required secret not set.}"

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

echo "Deploying ${GITHUB_REF} to ${WPE_ENV_NAME} ..." 

# Deploy Vars
WPE_SSH_HOST="$WPE_ENV_NAME.ssh.wpengine.net"
DIR_PATH="$INPUT_REMOTE_PATH"
SRC_PATH="$INPUT_SRC_PATH"
 
# Set up our user and path
WPE_SSH_USER="$WPE_ENV_NAME"@"$WPE_SSH_HOST"
WPE_FULL_HOST=wpe_gha+"$WPE_SSH_USER"
WPE_DESTINATION=wpe_gha+"$WPE_SSH_USER":sites/"$WPE_ENV_NAME"/"$DIR_PATH"


# Setup our SSH Connection & use keys
if [ ! -d "${HOME}"/.ssh ]; then 
    mkdir "${HOME}/.ssh" 
    SSH_PATH="${HOME}/.ssh" 
    mkdir "${SSH_PATH}/ctl/"
    # Set Key Perms 
    chmod -R 700 "$SSH_PATH"
  else 
  SSH_PATH="${HOME}/.ssh" 
  echo "using established SSH KEY path...";
fi

# Copy Secret Keys to container
WPE_SSHG_KEY_PRIVATE_PATH="$SSH_PATH/github_action"  
echo "$INPUT_WPE_SSHG_KEY_PRIVATE" > "$WPE_SSHG_KEY_PRIVATE_PATH"
chmod 600 "$WPE_SSHG_KEY_PRIVATE_PATH"

#establish known hosts
KNOWN_HOSTS_PATH="$SSH_PATH/known_hosts" 
ssh-keyscan -t rsa "$WPE_SSH_HOST" >> "$KNOWN_HOSTS_PATH" 
chmod 644 "$KNOWN_HOSTS_PATH"

echo "prepping file perms..."
find "$SRC_PATH" -type d -exec chmod -R 775 {} \;
find "$SRC_PATH" -type f -exec chmod -R 664 {} \;
echo "file perms set..."

# pre deploy php lint
if [ "${INPUT_PHP_LINT^^}" == "TRUE" ]; then
    echo "Begin PHP Linting."
    find "$SRC_PATH"/ -name "*.php" -type f -print0 | while IFS= read -r -d '' file; do
        php -l "$file"
        status=$?
        if [[ $status -ne 0 ]]; then
            echo "FAILURE: Linting failed - $file :: $status" && exit 1
        fi
    done
    echo "PHP Lint Successful! No errors detected!"
else 
    echo "Skipping PHP Linting."
fi

# post deploy script 
if [[ -n ${INPUT_SCRIPT} ]]; then 
    SCRIPT="&& sh ${INPUT_SCRIPT}";
  else 
    SCRIPT=""
fi 

# post deploy cache clear
if [ "${INPUT_CACHE_CLEAR^^}" == "TRUE" ]; then
    CACHE_CLEAR="&& wp --skip-plugins --skip-themes page-cache flush"
  elif [ "${INPUT_CACHE_CLEAR^^}" == "FALSE" ]; then
      CACHE_CLEAR=""
  else echo "CACHE_CLEAR must be TRUE or FALSE only... Cache not cleared..."  && exit 1;
fi

# Deploy via SSH
# setup master ssh connection 
ssh -nNf -v -i "${WPE_SSHG_KEY_PRIVATE_PATH}" -o StrictHostKeyChecking=no -o ControlMaster=yes -o ControlPath="$SSH_PATH/ctl/%C" "$WPE_FULL_HOST"

echo "!!! MASTER SSH CONNECTION ESTABLISHED !!!"
#rsync 
rsync --rsh="ssh -v -p 22 -i ${WPE_SSHG_KEY_PRIVATE_PATH} -o StrictHostKeyChecking=no -o 'ControlPath=$SSH_PATH/ctl/%C'" $INPUT_FLAGS --exclude-from='/exclude.txt' "$SRC_PATH" "$WPE_DESTINATION"

# post deploy script and cache clear
if [[ -n ${SCRIPT} || -n ${CACHE_CLEAR} ]]; then

    if [[ -n ${SCRIPT} ]]; then
      if ! ssh -v -p 22 -i "${WPE_SSHG_KEY_PRIVATE_PATH}" -o StrictHostKeyChecking=no -o ControlPath="$SSH_PATH/ctl/%C" "$WPE_FULL_HOST" "test -s sites/${WPE_ENV_NAME}/${INPUT_SCRIPT}"; then
        status=1
      fi

      if [[ $status -ne 0 && -f ${INPUT_SCRIPT} ]]; then
        ssh -v -p 22 -i "${WPE_SSHG_KEY_PRIVATE_PATH}" -o StrictHostKeyChecking=no -o ControlPath="$SSH_PATH/ctl/%C" "$WPE_FULL_HOST" "mkdir -p sites/${WPE_ENV_NAME}/$(dirname "${INPUT_SCRIPT}")"

        rsync --rsh="ssh -v -p 22 -i ${WPE_SSHG_KEY_PRIVATE_PATH} -o StrictHostKeyChecking=no -o 'ControlPath=$SSH_PATH/ctl/%C'" "${INPUT_SCRIPT}" "wpe_gha+$WPE_SSH_USER:sites/$WPE_ENV_NAME/$(dirname "${INPUT_SCRIPT}")"
      fi
    fi

    ssh -v -p 22 -i "${WPE_SSHG_KEY_PRIVATE_PATH}" -o StrictHostKeyChecking=no -o ControlPath="$SSH_PATH/ctl/%C" "$WPE_FULL_HOST" "cd sites/${WPE_ENV_NAME} ${SCRIPT} ${CACHE_CLEAR}"
fi 

#close master ssh 
ssh -O exit -o ControlPath="$SSH_PATH/ctl/%C" "$WPE_FULL_HOST"

echo "SUCCESS: Your code has been deployed to WP Engine!"