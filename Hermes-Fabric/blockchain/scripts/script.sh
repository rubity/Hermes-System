#!/bin/bash

echo
echo " ____    _____      _      ____    _____ "
echo "/ ___|  |_   _|    / \    |  _ \  |_   _|"
echo "\___ \    | |     / _ \   | |_) |   | |  "
echo " ___) |   | |    / ___ \  |  _ <    | |  "
echo "|____/    |_|   /_/   \_\ |_| \_\   |_|  "
echo
echo "Build your first network (BYFN) end-to-end test"
echo
CHANNEL_NAME="$1"
DELAY="$2"
LANGUAGE="$3"
TIMEOUT="$4"
VERBOSE="$5"
NO_CHAINCODE="$6"
: ${CHANNEL_NAME:="mychannel"}
: ${DELAY:="3"}
: ${LANGUAGE:="golang"}
: ${TIMEOUT:="10"}
: ${VERBOSE:="false"}
: ${NO_CHAINCODE:="false"}
LANGUAGE=`echo "$LANGUAGE" | tr [:upper:] [:lower:]`
COUNTER=1
MAX_RETRY=10

CC_SRC_PATH="github.com/chaincode/fabHermes/"

echo "Channel name : "$CHANNEL_NAME

# import utils
. scripts/utils.sh

createChannel() {
	setGlobals 0 "inmetro.com"

	if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                set -x
		peer channel create -o orderer.inmetro.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx >&log.txt
		res=$?
                set +x
	else
				set -x
		peer channel create -o orderer.inmetro.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
		res=$?
				set +x
	fi
	cat log.txt
	verifyResult $res "Channel creation failed"
	echo "===================== Channel '$CHANNEL_NAME' created ===================== "
	echo
}

joinChannel () {
	for org in inmetro.com nanoBusiness.com ird.com; do
	    for peer in 0 1; do
		    joinChannelWithRetry $peer $org
		    echo "===================== peer${peer}.${org} joined channel '$CHANNEL_NAME' ===================== "
		    sleep $DELAY
		    echo
	    done
	done
}

## Create channel
echo "Creating channel..."
createChannel

## Join all the peers to the channel
echo "Having all peers join the channel..."
joinChannel

## Set the anchor peers for each org in the channel
echo "Updating anchor peers for org1..."
updateAnchorPeers 0 "inmetro.com"

echo "Updating anchor peers for org2..."
updateAnchorPeers 0 "nanoBusiness.com"

echo "Updating anchor peers for org3..."
updateAnchorPeers 0 "ird.com"

if [ "${NO_CHAINCODE}" != "true" ]; then

	## Install chaincode on peers
	echo "Installing chaincode on peer0.inmetro..."
	installChaincode 0 "inmetro.com"
	
	echo "Installing chaincode on peer1.inmetro..."
	installChaincode 1 "inmetro.com"
	
	echo "Installing chaincode on peer0.nanoBusiness..."
	installChaincode 0 "nanoBusiness.com"
	
	echo "Installing chaincode on peer1.nanoBusiness..."
	installChaincode 1 "nanoBusiness.com"

	echo "Installing chaincode on peer0.ird..."
	installChaincode 0 "ird.com"
	
	echo "Installing chaincode on peer0.ird..."
	installChaincode 1 "ird.com"

	# Query chaincode on peer0.org1
	#echo "Querying chaincode on peer0.org1..."
	#chaincodeQuery 0 1 100

	# Invoke chaincode on peer0.org1 and peer0.org2
	#echo "Sending invoke transaction on peer0.org1 peer0.org2..."
	#chaincodeInvoke 0 1 0 2
	
	## Instantiate chaincode chaincode on peers
	echo "Instantiating chaincode on peer0.inmetro..."
	instantiateChaincode 0 "inmetro.com"
	

	# Query on chaincode on peer1.org2, check if the result is 90
	#echo "Querying chaincode on peer1.org2..."
	#chaincodeQuery 1 2 90
	
fi

echo
echo "========= All GOOD, BYFN execution completed =========== "
echo

echo
echo " _____   _   _   ____   "
echo "| ____| | \ | | |  _ \  "
echo "|  _|   |  \| | | | | | "
echo "| |___  | |\  | | |_| | "
echo "|_____| |_| \_| |____/  "
echo

exit 0
