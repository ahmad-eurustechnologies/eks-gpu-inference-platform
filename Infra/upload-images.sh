#!/usr/bin/env bash
set -e

echo "Starting load test..."

# NOTE: the following command is a one-time setup to set the password for the user "ahmad" in the Cognito user pool. It is commented out because it only needs to be run once, and running it again would reset the password. If you need to reset the password, copy and run this command with a new password.
# aws cognito-idp admin-set-user-password \
#   --user-pool-id <user-pool-id> \
#   --username ahmad \
#   --password <password> \
#   --permanent

TOKEN=$(aws cognito-idp initiate-auth \
  --auth-flow USER_PASSWORD_AUTH \
  --client-id <client-id> \ 
  --auth-parameters USERNAME=ahmad,PASSWORD=<PASSWORD> \
  --query 'AuthenticationResult.IdToken' --output text)
echo $TOKEN
# COCO dataset: https://cocodataset.org/#download 2017 val images [5K/1GB]
for img in $(find ../val2017 -name '*.jpg' | head -"${1:-205}"); do
  curl -X POST https://upload.ahmadk.link/upload \
    -H "Authorization: Bearer $TOKEN" \
    -F "file=@$img;type=image/jpeg" &
    
    echo "Uploaded $img"
done
wait
