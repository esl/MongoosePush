#!/bin/bash

docker network create n

docker run -p 4000:4000 -p 4001:4001 --name fcm --network n mongooseim/fcm-mock-server

docker run -v `pwd`/priv:/opt/app/priv -e PUSH_FCM_ENABLED=true -e PUSH_FCM_PORT=4000 -e PUSH_FCM_ENDPOINT="fcm" -e PUSH_APNS_ENABLED=false -e TLS_SERVER_CERT_VALIDATION=false -e FCM_AUTH_ENDPOINT="http://fcm:4001" --network n -p 8443:8443 mongooseim/mongoose-push:zp_integration-tests

docker run -v `pwd`/priv:/opt/app/priv -e PUSH_FCM_ENABLE=false -e PUSH_APNS_ENABLED=true -e PUSH_APNS_PROD_ENDPOINT="apns" -e TLS_SERVER_CERT_VALIDATION=false -e PUSH_APNS_PROD_USE_2197=true -e PUSH_APNS_AUTH_TYPE=certificate -e PUSH_APNS_DEV_ENDPOINT="apns" -e PUSH_APNS_DEV_USE_2197=true --network n -p 8443:8443 mongooseim/mongoose-push:zp_integration-test

MIX_ENV=integration mix test test/api --only integration
