# The Hermes-Fabric project

This repository contains the implementation of the **Hermes-Fabric**, developed at the Instituto Nacional de Metrologia, Qualidade e Tecnologia (Inmetro).

Research team:

* *Carlos Augusto R. de Oliveira (caruviaro@outlook.com)*

## What the Hermes-Fabric is

The Hermes-Fabric project is an application that aims, through a blockchain network, to ensure the security and reliability of stored data.

We adopt [Hyperledger Fabric 1.4 LTS](https://hyperledger-fabric.readthedocs.io/en/release-1.4/) as our blockchain platform.

We describe in the next sections the main aspects related to the Fabric blockchain network customizing, the chaincode development  and the application client created to put all the stuff together.

## The customized blockchain network

We use a Fabric blockchain network with six ordinary peers (one of them being an endorser) and the solo orderer service. We also use [couchdb](https://hyperledger-fabric.readthedocs.io/en/release-1.4/couchdb_tutorial.html) containers to improve the performance on storing the ledger state on each peer.

All the configuration files related to the blockchain network  are in the folder [blockchain](blockchain). The main files are:

* [configtx.yaml](blockchain/configtx.yaml): contains the network profile of our Fabric blockchain network.
* [crypto-config-inmetro.yaml](blockchain/crypto-config-inmetro.yaml): contains the MSP (Membership Service Provider) configuration. We generate all the digital certificates from it.
* [docker-compose-inmetro.yaml](blockchain/base/docker-compose-base.yaml): contains the docker containers configuration. It extends the file [peer-base.yaml](blockchain/base/peer-base.yaml) which constitutes a template of standard configuration items.

If you are not used to the Hyperledger Fabric, we strongly recommend this [tutorial](https://hyperledger-fabric.readthedocs.io/en/release-1.4/build_network.html). It teachs in details how to create a basic Fabric network.

The Hermes-Fabric network can be started by executing the steps described in the following subsections. All the commands must be executed into the folder blockchain.

### 1. Prepare the host machine

You need to install the **Hyperledger Fabric 1.4 LTS** basic software and [dependencies](https://hyperledger-fabric.readthedocs.io/en/release-1.4/prereqs.html). Again, we try to make things simpler to you by providing a shell script that installs all these stuffs in a clean **Ubuntu 18.04 LTS** system. If you are using this distribution, our script works for you. If you have a different distribution, you can still try the script or you can customize it to work in your system.

Execute the [installation script](prerequirements/installFabric.sh):

```console
./installFabric.sh
```

**OBSERVATION**: you do not need to run the script as *sudo*. The script will automatically ask for your *sudo* password when necessary. That is important to keep the docker containers running with your working user account.

### 3. Manage the network

In the folder [blockchain](blockchain), execute the following script to start the network:

```console
./startFabric.sh
```

This script uses [configtx.yaml](blockchain/configtx.yaml) and [crypto-config.yaml](blockchain/crypto-config.yaml) to create the MSP certificates in the folder (blockchain/crypto-config). It also generates the genesis block file *genesis.block* and the channel configuration file *channel.tx*. Noticed that this script depends on the tools installed together with Fabric. The script *installFabric.sh* executed previously is expected to modify your $PATH variable and enable the direct execution of the Fabric tools. If this does not happen, try to fix the $PATH manually. The tools usually are located in the folder /$HOME/fabric_samples/bin.

After generating the certificates, the script will raise all the containers on the network.

If you succeed in coming so far, the Hyperledger Fabric shall be running in your machine. You can see information from the containers by using the following commands:

```console
docker ps
docker stats
```

Use the following command to stop the network:

```console
./byfn.sh -m down
```

## The fabmorph chaincode

In this document, we assume you already know how to implement and deploy a chaincode in Fabric. If this is not your case, there is a [nice tutorial](https://hyperledger-fabric.readthedocs.io/en/release-1.4/chaincode4ade.html) that covers a lot of information about this issue. We strongly recomend you to check it before to continue.

If you already know everything you need about developing and deploying a chaincode, we can introduce the **fabHermes** chaincode. It contains basic methods required to enter and request blockchain data. The chaincode source code is [here](../chaincode/fabHermes/fabHermes.go).

If you need to modify, compile and test the **fabmorph** chaincode, be sure that you have the [Golang *shim* interface](https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim) properly installed in your machine. If you do not have it, you can install it by using the following command:

```console
go get -u github.com/hyperledger/fabric/core/chaincode/shim
```

### Shell commands to deal with a Fabric chaincode

Our blockchain network profile includes the client container *cli* which is provided only to execute tests with the chaincode. The *cli* is able to communicate with the blockchain network using the peer *peer0.ptb.de* as an anchor and so execute commands for installing, mantaining and testing the chaincode. These commands documentation can be find [here](https://hyperledger-fabric.readthedocs.io/en/release-1.4/commands/peerchaincode.html). We strongly recommend you read this documentation before continuing.

#### 2. Invoking and/or querying a chaincode

We can also use the same structure of commands in *cli* to test our chaincode. Here we present some examples about how you can do that.

If you want to invoke the *insertMeasurement* chaincode method, you can use such command for example:

```console
docker exec cli peer chaincode invoke -o orderer.inmetro.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/inmetro.com/orderers/orderer.inmetro.com/msp/tlscacerts/tlsca.inmetro.com-cert.pem -C mychannel -n mycc --peerAddresses peer0.inmetro.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/inmetro.com/peers/peer0.inmetro.com/tls/ca.crt -c '{"Args":["insertMeasurement","666","{\r\n   \"id\":\"666\",\r\n   \"sensor\":\"DHT\",\r\n   \"value\":24.7,\r\n   \"Timestamp\":0.75,\r\n   \"location\":\"laboratorio\",\r\n   \"physicalQuantity\":\"Temperatura\"\r\n}"]}'
```

After, you can retrieve the measurement consumption in the register made previously, by executing the command:

```console
docker exec cli peer chaincode invoke -o orderer.inmetro.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/inmetro.com/orderers/orderer.inmetro.com/msp/tlscacerts/tlsca.inmetro.com-cert.pem -C $CHANNEL_NAME -n mycc -c '{"Args":["queryHistory","666"]}'
```

## The Client Application

The Client Application is a module that uses the chaincode services provided by the blockchain network. All client modules are written in Python 3.

### Get pip3

Install the Python PIP3 using the following command:

```console
sudo apt install python3-pip
```

OBSERVATION: About the pip3, aware some packages can require specific versions due to compatibility issues. You can get a specific version using the following sintaxe:

```console
pip3 install -U 'pysha3 == 1.0b1'
```

### Get the Fabric Python SDK

The [Fabric Python SDK](https://github.com/hyperledger/fabric-sdk-py) is not part of the Hyperledger Project. It is maintained by an independent community of users from Fabric. However, this SDK works fine, at least to the basic functionalities we need.

You need to install the Python SDK dependencies first:

```console
sudo apt-get install python-dev python3-dev libssl-dev
```

After, install the Python SDK using *git*. Notice that the repository will be cloned into the current path, so we recommend you install it in your $HOME directory.

```console
cd $HOME
git clone https://github.com/hyperledger/fabric-sdk-py.git
cd fabric-sdk-py
sudo make install
```

### The Client Application

The Client Application includes the following modules:

* [insertbBlockchain.py](clients/insertBlockchain.py): The insertBlockchain client is responsible for collecting data from an application in json format and calling chaincode methods to insert this data into the blockchain. 
* [queryHistory.py](clients/queryHistory.py): Queries all transactions present in the ledger for an id.
* [getConsumption.py](clients/getConsumption): Use CouchDB to query the transactions.

### Hyperledger Explorer

[Hyperledger Explorer](https://www.hyperledger.org/projects/explorer) is a blockchain module and one of the Hyperledger projects hosted by The Linux Foundation. Designed to create a user-friendly Web application, Hyperledger Explorer can view, invoke, deploy or query blocks, transactions and associated data, network information (name, status, list of nodes), chain codes and transaction families, as well as any other relevant information stored in the ledger. Hyperledger Explorer was initially contributed by IBM, Intel and DTCC. Check the current status of Hyperledger Explorer [here](https://github.com/hyperledger/blockchain-explorer/blob/master/README.md).

#### Requirements ####

- [Nodejs](https://nodejs.org/en/) 8.11.X (Note that v9.x is not yet supported)
- [Jq](https://stedolan.github.io/jq/)
- [PostgreSQL](https://www.postgresql.org/) 9.5 or greater

#### How to use Hyperledger Explorer ? ####


The following is the step by step to install Hyperledger explorer:

Download the latest version of the cURL tool if it is not already installed or if you get errors running the curl commands from the documentation.

```console
sudo apt-get install curl
```

After this, clone Hyperledger Explorer.

```console
cd /home
git clone https://github.com/hyperledger/blockchain-explorer.git
```

You can modify explorerconfig.json to update postgresql properties.

```console
cd blockchain-explorer/app
gedit explorerconfig.json
```

In some case you may need to apply permission to db

```console
cd /persistence/fabric/postgreSQL
chmod -R 775 db/
```

Run create database script.

```console
cd /db
./createdb.sh
sudo -u postgres psql
```

- \l view created fabricexplorer database

- \d view created tables

Now, I will modify config.json to update network-configs.
change “fabric-path” to your fabric network path, example

```console
cd ../../../../platform/fabric
gedit config.json
```

Now, we have to build Hyperledger Explorer

```console
cd blockchain-explorer
npm install
cd blockchain-explorer/app/test
npm install
npm run test
cd client/
npm install
npm test -- -u --coverage
npm run build
```

It's normal get some errors.

```console
cd /home/blockchain-explorer/
./main.sh install
./start.sh
```

Your Hyperledger Explorer should be properly set up and you can access it at http://0.0.0.0:8080

