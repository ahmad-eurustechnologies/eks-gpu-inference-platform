#!/usr/bin/env bash
set -e
export AWS_USE_DUALSTACK_ENDPOINT=false
echo "Starting Demo..."

CLIENT_ID=$(terraform -chdir=app output -raw cognito_client_id)
POOL_ID=$(terraform -chdir=app output -raw cognito_user_pool_id)

# password_policy on the pool is minimum_length=8, no complexity required, so
# any random string of this length satisfies it. Generated fresh each run and
# set as permanent so initiate-auth doesn't hit FORCE_CHANGE_PASSWORD.
PASSWORD=$(openssl rand -base64 16)

echo "PASSWORD"
echo $PASSWORD

aws cognito-idp admin-set-user-password \
  --user-pool-id $POOL_ID \
  --username ahmad \
  --password $PASSWORD \
  --permanent

TOKEN=$(aws cognito-idp initiate-auth \
  --auth-flow USER_PASSWORD_AUTH \
  --client-id $CLIENT_ID \
  --auth-parameters USERNAME=ahmad,PASSWORD=$PASSWORD \
  --query 'AuthenticationResult.IdToken' --output text)
echo "$TOKEN"
# COCO dataset: https://cocodataset.org/#download 2017 val images [5K/1GB]
for img in $(find ../val2017 -name '*.jpg' | head -"${1:-205}"); do
  curl -X POST https://upload.ahmadk.link/upload \
    -H "Authorization: Bearer $TOKEN" \
    -F "file=@$img;type=image/jpeg" &

  echo "Uploaded $img"
done
wait
