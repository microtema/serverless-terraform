#!/bin/bash
set -eux
#assign credentials to variables
USER_POOL_ID=eu-central-1_4YDAkfmgT
CLIENT_ID=287u3c6j4rmhu2rpnmh7u4934f
USERNAME=microtema@yahoo.com
PASSWORD=fooBar@1234
URL=https://ct9sff8pji.execute-api.eu-central-1.amazonaws.com/prod/auth?product_id=1
#sign-up user:
aws cognito-idp sign-up --client-id ${CLIENT_ID} --username ${USERNAME} --password ${PASSWORD}

#confirm user:
aws cognito-idp admin-confirm-sign-up --user-pool-id ${USER_POOL_ID} --username ${USERNAME}

#authenticate and get token
TOKEN=$(aws cognito-idp initiate-auth --client-id ${CLIENT_ID} --auth-flow USER_PASSWORD_AUTH --auth-parameters USERNAME=${USERNAME},PASSWORD=${PASSWORD} --query 'AuthenticationResult.IdToken' --output text)
#make API call:
curl -H "Authorization: ${TOKEN}" ${URL}
