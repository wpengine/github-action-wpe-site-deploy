#!/bin/sh

BACKUP_DIR=/tmp
PLUGINS_DIR=wp-content/plugins
PLUGIN_NAME=test-plugin
STATUS_FILE=status.json

cleanup() {
    rm tests/data/post-deploy/test-plugin.sh
}
trap cleanup EXIT

# Get the the new plugin version
AFTER_PLUGIN_VERSION=$(wp plugin get $PLUGIN_NAME | sed -n "/version/p" | cut -f2)
echo "New test plugin version: $AFTER_PLUGIN_VERSION"

# Revert to backup created by rsync if it exists
if [ -d $BACKUP_DIR/$PLUGIN_NAME ]; then
    rm -rf $PLUGINS_DIR/$PLUGIN_NAME && mv $BACKUP_DIR/$PLUGIN_NAME $PLUGINS_DIR/
fi

# Get the old plugin version
BEFORE_PLUGIN_VERSION=$(wp plugin get $PLUGIN_NAME | sed -n "/version/p" | cut -f2)
echo "Old test plugin version: $BEFORE_PLUGIN_VERSION"

# Check that the expected update was made
if [ -z "$BEFORE_PLUGIN_VERSION" ] || [ -z "$AFTER_PLUGIN_VERSION" ] || [ "$BEFORE_PLUGIN_VERSION" = "$AFTER_PLUGIN_VERSION" ]; then
    echo "Failure: Test plugin was not updated!"
    echo "{\"status\": \"failure\"}" > $PLUGINS_DIR/$PLUGIN_NAME/$STATUS_FILE
else
    echo "Success: Test plugin successfully updated from $BEFORE_PLUGIN_VERSION to $AFTER_PLUGIN_VERSION!"
    echo "{\"status\": \"success\"}" > $PLUGINS_DIR/$PLUGIN_NAME/$STATUS_FILE
fi