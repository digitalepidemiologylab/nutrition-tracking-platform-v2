#!/bin/bash
set -e

echo
echo "-----------------------------"
echo "| 🔐 Rotate AWS credentials |"
echo "-----------------------------"
echo

###
# Check if all CLI/tools are installed
###

if type aws > /dev/null 2>&1; then
  echo "✅ AWS CLI installed"
else
  echo "❌ AWS CLI is not installed, please follow the instructions here: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
  exit 1
fi

if type jq > /dev/null 2>&1; then
  echo "✅ jq installed"
else
  echo "❌ jq is not installed, please follow the instructions here: https://stedolan.github.io/jq/download/"
  exit 1
fi

if type op > /dev/null 2>&1; then
  echo "✅ 1Password CLI installed"
else
  echo "❌ 1Password CLI is not installed, please follow the instructions here: https://support.1password.com/command-line-getting-started/"
  exit 1
fi

###
# 1Password Signin
#
# If the there is an error on the first try, we show the complete signin (which required to put the secret key)
###

echo
{
  op_token=$(op signin delab -r)
} || {
  {
    echo
    echo "⚠️  Wrong password or your 1Password account for \"delab\" is not on this device, please provide the following info:"
    echo
    read -p "⌨️  Enter your 1Password email: " op_email
    op_token=$(op signin delab.1password.com $op_email -r)
  } || {
    echo "❌ 1Password: bad credentials."
    exit 1
  }
}

###
# Save MyFoodRepo2 1Password vault name in a variable
###

op_vault="MyFoodRepo2"

###
# Ask on which environment we want you change the AWS API keys
###

echo
echo "ℹ️  You need to choose the environment where you want to rotate the AWS API keys (\"staging\" or \"production\"):"
echo
read -p "⌨️  Enter the environment name: " environment_name
echo

###
# Query 1Password to get the item for the AWS API keys
###

{
  op_item_json=$(op get item "$op_item_name" --fields AWSUserName,AWSSecretAccessKey,AWSAccessKeyId --vault "$op_vault" --session $op_token)
} || {
  echo "❌ 1Password: can't find \"$op_item_name\" item in \"$op_vault\" vault."
  exit 1
}

###
# Test if the item found has `AWSUserName`, `AWSSecretAccessKey` and `AWSAccessKeyId` attributes
###

op_item_keys="$(jq --sort-keys -r 'keys | join(",")' <<< $op_item_json)"
if [[ $op_item_keys != "AWSAccessKeyId,AWSSecretAccessKey,AWSUserName" ]]; then
  echo "❌ The 1Password item needs to have AWSUserName, AWSAccessKeyId and AWSSecretAccessKey attributes."
  exit 1
fi

aws_user_name=$(jq -r '.AWSUserName' <<< "$op_item_json")
aws_old_key_on_1password=$(jq -r '.AWSAccessKeyId' <<< "$op_item_json")

###
# Show the AWS user name found in 1Password
###

echo
echo "ℹ️  AWS IAM user found: \"$aws_user_name\""
echo

###
# Ask for AWS CLI profile and use "default" if empty
###

read -p "⌨️  Enter your AWS profile [default]: " aws_profile
aws_profile=${aws_profile:-default}
echo

###
# Get the list of keys on AWS and show an error if something goes wrong
###

{
  aws_list_keys_json=$(aws iam list-access-keys --user-name $aws_user_name --profile $aws_profile --output json)
} || {
  echo "❌ The AWS CLI can't access to the access keys, please be sure to have AWS CLI configured with the following command:"
  echo '"aws configure list" (use --profile {yourProfileName} if you use a profile)'
  echo "If you have no access_key/secret_key set, please read the instructions here: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html#cli-configure-quickstart-config"
  exit 1
}

###
# Check the number of active keys (should be 1)
###

active_key_number=$(jq '.AccessKeyMetadata | map(select(.Status=="Active")) | length' <<< "$aws_list_keys_json")
if [[ $active_key_number != 1 ]]; then
  echo "❌ The IAM user on AWS should have only 1 active key. Please check why it's not the case on the IAM AWS console."
  exit 1
fi

###
# Check if the AWS key ID found on AWS is the same as the one on 1Password
###

aws_old_key=$(jq -r '.AccessKeyMetadata | map(select(.Status=="Active")) | first.AccessKeyId' <<< "$aws_list_keys_json")
if [[ $aws_old_key_on_1password != $aws_old_key ]]; then
  echo "❌ The AWS access key on 1Password is not the same as the access key on AWS, please verify this point."
  exit 1
fi

###
# Confirm script next steps
###

echo "ℹ️  Until now the script has not changed anything permanently. Now the script will."
read -p "⌨️  Do you want to continue? [Y/n]? " confirm_continue
confirm_continue=${confirm_continue:-y}
echo

if [[ ! $confirm_continue =~ [yY](es)* ]]; then
  echo "❌ Script aborted by the user."
  exit 1
fi

###
# Check if there is a inactive key and ask to remove it if there is one (AWS supports max 2 keys per user)
###

inactive_key_number=$(jq '.AccessKeyMetadata | map(select(.Status=="Inactive")) | length' <<< "$aws_list_keys_json")
if [[ $inactive_key_number != 0 ]]; then
  inactive_key=$(jq -r '.AccessKeyMetadata | map(select(.Status=="Inactive")) | first.AccessKeyId' <<< "$aws_list_keys_json")

  echo "ℹ️  There is a maximum of two keys per user. You must remove the inactive key."
  echo
  read -p "⌨️  Do you want to remove inactive key \"$inactive_key\" [Y/n]? " remove_inactive_key_choice
  remove_inactive_key_choice=${remove_inactive_key_choice:-y}
  echo

  if [[ $remove_inactive_key_choice =~ [yY](es)* ]]; then
    aws iam delete-access-key --access-key-id $inactive_key --user-name $aws_user_name --profile $aws_profile --output json
    echo "ℹ️  \"$inactive_key\" inactive key removed."
  else
    echo "❌ Script aborted: the inactive key must be removed before to create a new key."
    exit 1
  fi
fi

###
# Create the new AWS API key
###

aws_new_key_json=$(aws iam create-access-key --user-name $aws_user_name --profile $aws_profile --output json)
aws_new_key=$(jq -r '.AccessKey.AccessKeyId' <<< "$aws_new_key_json")
aws_new_secret=$(jq -r '.AccessKey.SecretAccessKey' <<< "$aws_new_key_json")
echo "ℹ️  New \"$aws_new_key\" key created and active."

###
# Save the new AWS key to 1Password
###

op edit item "$op_item_name" --vault "$op_vault" --session $op_token AWSAccessKeyId="$aws_new_key" AWSSecretAccessKey="$aws_new_secret"
echo "ℹ️  New \"$aws_new_key\" key saved in 1Password."

###
# Set inactive the old AWS API key
###

aws iam update-access-key --access-key-id $aws_old_key --status Inactive --user-name $aws_user_name --profile $aws_profile --output json
echo "ℹ️  Old \"$aws_old_key\" key is now inactive."
echo
echo "🍻 The AWS keys have been rotated successfully!"
