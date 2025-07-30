#!/bin/bash

echo "Starting post-provision script..."

set -e

# Get environment variables from azd
RESOURCE_GROUP_NAME=$AZURE_RESOURCE_GROUP_NAME
SUBSCRIPTION_ID=$AZURE_SUBSCRIPTION_ID
LOCATION=$AZURE_LOCATION

echo "Resource Group: $RESOURCE_GROUP_NAME"
echo "Subscription: $SUBSCRIPTION_ID"
echo "Location: $LOCATION"

# Check if Azure CLI is available
if ! command -v az &> /dev/null; then
    echo "Azure CLI is not installed or not in PATH"
    exit 1
fi

# Check if logged in to Azure
if ! az account show &> /dev/null; then
    echo "Logging into Azure..."
    az login
fi

# Set the correct subscription
if [ -n "$SUBSCRIPTION_ID" ]; then
    echo "Setting subscription to: $SUBSCRIPTION_ID"
    az account set --subscription "$SUBSCRIPTION_ID"
fi

echo "Post-provision script completed successfully!"
