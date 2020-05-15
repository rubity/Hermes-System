#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# Exit on first error
set -e

# don't rewrite paths for Windows Git Bash users
export MSYS_NO_PATHCONV=1
starttime=$(date +%s)
CC_SRC_LANGUAGE=${1:-"go"}
CC_SRC_LANGUAGE=`echo "$CC_SRC_LANGUAGE" | tr [:upper:] [:lower:]`
if [ "$CC_SRC_LANGUAGE" = "go" -o "$CC_SRC_LANGUAGE" = "golang"  ]; then
	CC_RUNTIME_LANGUAGE=golang
	CC_SRC_PATH=github.com/chaincode/fabHermes
elif [ "$CC_SRC_LANGUAGE" = "java" ]; then
	CC_RUNTIME_LANGUAGE=java
	CC_SRC_PATH=/opt/gopath/src/github.com/chaincode/fabcar/java
elif [ "$CC_SRC_LANGUAGE" = "javascript" ]; then
	CC_RUNTIME_LANGUAGE=node # chaincode runtime language is node.js
	CC_SRC_PATH=/opt/gopath/src/github.com/chaincode/fabcar/javascript
elif [ "$CC_SRC_LANGUAGE" = "typescript" ]; then
	CC_RUNTIME_LANGUAGE=node # chaincode runtime language is node.js
	CC_SRC_PATH=/opt/gopath/src/github.com/chaincode/fabcar/typescript
	echo Compiling TypeScript code into JavaScript ...
	pushd ../chaincode/fabcar/typescript
	npm install
	npm run build
	popd
	echo Finished compiling TypeScript code into JavaScript
else
	echo The chaincode language ${CC_SRC_LANGUAGE} is not supported by this script
	echo Supported chaincode languages are: go, javascript, and typescript
	exit 1
fi


# clean the keystore
rm -rf ./hfc-key-store

# launch network; create channel and join peer to channel
echo y | ./byfn.sh down
echo y | ./byfn.sh up -a -n -s couchdb

CONFIG_ROOT=/opt/gopath/src/github.com/hyperledger/fabric/peer
INMETRO_MSPCONFIGPATH=${CONFIG_ROOT}/crypto/peerOrganizations/inmetro.com/users/Admin@inmetro.com/msp
INMETRO_TLS_ROOTCERT_FILE=${CONFIG_ROOT}/crypto/peerOrganizations/inmetro.com/peers/peer0.inmetro.com/tls/ca.crt
NANOBUSINESS_MSPCONFIGPATH=${CONFIG_ROOT}/crypto/peerOrganizations/nanoBusiness.com/users/Admin@nanoBusiness.com/msp
NANOBUSINESS_TLS_ROOTCERT_FILE=${CONFIG_ROOT}/crypto/peerOrganizations/nanoBusiness.com/peers/peer0.nanoBusiness.com/tls/ca.crt
ORDERER_TLS_ROOTCERT_FILE=${CONFIG_ROOT}/crypto/ordererOrganizations/inmetro.com/orderers/orderer.inmetro.com/msp/tlscacerts/tlsca.inmetro.com-cert.pem
set -x

echo "Installing smart contract on peer0.inmetro.com"
docker exec \
  -e CORE_PEER_LOCALMSPID=InmetroMSP \
  -e CORE_PEER_ADDRESS=peer0.inmetro.com:7051 \
  -e CORE_PEER_MSPCONFIGPATH=${INMETRO_MSPCONFIGPATH} \
  -e CORE_PEER_TLS_ROOTCERT_FILE=${INMETRO_TLS_ROOTCERT_FILE} \
  cli \
  peer chaincode install \
    -n mycc \
    -v 1.0 \
    -p "$CC_SRC_PATH" \
    -l "$CC_RUNTIME_LANGUAGE"

echo "Installing smart contract on peer0.nanoBusiness.com"
docker exec \
  -e CORE_PEER_LOCALMSPID=NanoBusinessMSP \
  -e CORE_PEER_ADDRESS=peer0.nanoBusiness.com:9051 \
  -e CORE_PEER_MSPCONFIGPATH=${NANOBUSINESS_MSPCONFIGPATH} \
  -e CORE_PEER_TLS_ROOTCERT_FILE=${NANOBUSINESS_TLS_ROOTCERT_FILE} \
  cli \
  peer chaincode install \
    -n mycc \
    -v 1.0 \
    -p "$CC_SRC_PATH" \
    -l "$CC_RUNTIME_LANGUAGE"

echo "Instantiating smart contract on mychannel"
docker exec \
  -e CORE_PEER_LOCALMSPID=InmetroMSP \
  -e CORE_PEER_MSPCONFIGPATH=${INMETRO_MSPCONFIGPATH} \
  cli \
  peer chaincode instantiate \
    -o orderer.inmetro.com:7050 \
    -C mychannel \
    -n mycc \
    -l "$CC_RUNTIME_LANGUAGE" \
    -v 1.0 \
    -c '{"Args":[]}' \
    --tls \
    --cafile ${ORDERER_TLS_ROOTCERT_FILE} \
    --peerAddresses peer0.inmetro.com:7051 \
    --tlsRootCertFiles ${INMETRO_TLS_ROOTCERT_FILE}

echo "Waiting for instantiation request to be committed ..."
sleep 10

echo "Submitting initLedger transaction to smart contract on mychannel"
echo "The transaction is sent to the two peers with the chaincode installed (peer0.inmetro.com and peer0.nanoBusiness.com) so that chaincode is built before receiving the following requests"
docker exec \
  -e CORE_PEER_LOCALMSPID=InmetroMSP \
  -e CORE_PEER_MSPCONFIGPATH=${INMETRO_MSPCONFIGPATH} \
  cli \
  peer chaincode invoke \
    -o orderer.inmetro.com:7050 \
    -C mychannel \
    -n mycc \
    -c '{"Args":["initLedger"]}' \
    --waitForEvent \
    --tls \
    --cafile ${ORDERER_TLS_ROOTCERT_FILE} \
    --peerAddresses peer0.inmetro.com:7051 \
    --peerAddresses peer0.nanoBusiness.com:9051 \
    --tlsRootCertFiles ${INMETRO_TLS_ROOTCERT_FILE} \
    --tlsRootCertFiles ${NANOBUSINESS_TLS_ROOTCERT_FILE}
set +x

cat <<EOF

Total setup execution time : $(($(date +%s) - starttime)) secs ...

Next, use the FabCar applications to interact with the deployed FabCar contract.
The FabCar applications are available in multiple programming languages.
Follow the instructions for the programming language of your choice:

JavaScript:

  Start by changing into the "javascript" directory:
    cd javascript

  Next, install all required packages:
    npm install

  Then run the following applications to enroll the admin user, and register a new user
  called user1 which will be used by the other applications to interact with the deployed
  FabCar contract:
    node enrollAdmin
    node registerUser

  You can run the invoke application as follows. By default, the invoke application will
  create a new car, but you can update the application to submit other transactions:
    node invoke

  You can run the query application as follows. By default, the query application will
  return all cars, but you can update the application to evaluate other transactions:
    node query

TypeScript:

  Start by changing into the "typescript" directory:
    cd typescript

  Next, install all required packages:
    npm install

  Next, compile the TypeScript code into JavaScript:
    npm run build

  Then run the following applications to enroll the admin user, and register a new user
  called user1 which will be used by the other applications to interact with the deployed
  FabCar contract:
    node dist/enrollAdmin
    node dist/registerUser

  You can run the invoke application as follows. By default, the invoke application will
  create a new car, but you can update the application to submit other transactions:
    node dist/invoke

  You can run the query application as follows. By default, the query application will
  return all cars, but you can update the application to evaluate other transactions:
    node dist/query

Java:

  Start by changing into the "java" directory:
    cd java

  Then, install dependencies and run the test using:
    mvn test

  The test will invoke the sample client app which perform the following:
    - Enroll admin and user1 and import them into the wallet (if they don't already exist there)
    - Submit a transaction to create a new car
    - Evaluate a transaction (query) to return details of this car
    - Submit a transaction to change the owner of this car
    - Evaluate a transaction (query) to return the updated details of this car

EOF
