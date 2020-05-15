# The Hermes-Ethereum project

This repository contains the implementation of the **Hermes-Ethereum**, developed at the Instituto Nacional de Metrologia, Qualidade e Tecnologia (Inmetro).

Research team:

* *Ramon Rocha Rezende (ramonrocharezende@gmail.com)*

## What the Hermes-Ethereum is

The Hermes-Ethereum project is an application that aims, through a blockchain network, to ensure the security and reliability of stored data.

We adopt [Ethereum](https://github.com/ethereum/wiki/wiki) as our blockchain platform. We are using the Rinkeby testnet.


## The Client Application

The Client Application is a module that uses the chaincode services provided by the blockchain network. All client modules are written in Python 3.

### Get pip3

Install the Python PIP3 using the following command:

```console
sudo apt install python3-pip
```

### Installing the Solidity compiler

Solidity is the language in which our smart contracts will be written.
We need the compiler so we can generate the bytecodes from our source code.

```console
sudo add-apt-repository ppa:ethereum/ethereum
sudo apt-get update
sudo apt-get install solc
```

### Compiling smart contracts

Create folder for compiled contracts
```console
cd /path/hades-project/Hermes-Ethereum
mkdir compiled
```

Execute script
```console
cd /path/hades-project/Hermes-Ethereum/scripts
./compile-contract.sh
```

### Get the web3py

The web3py is the library for communicating with ethereum. It is derived from the web3js javascript library.

```console
cd /path/hades-project/Hermes-Ethereum/
pip3 install -r requirements.txt
```

### Get the Go Ethereum

```console
sudo add-apt-repository -y ppa:ethereum/ethereum
sudo apt-get update
sudo apt-get install ethereum
```

### Syncing with the Ethereum network

To interact with ethereum we first need to synchronize with the network.
```console
geth --rinkeby --syncmode full
```

### The Client Application

The Client Application includes the following modules:

* [insertbBlockchain.py](clients/insertBlockchain.py): The insertBlockchain client is responsible for collecting data from an application in json format and calling chaincode methods to insert this data into the blockchain. 
* [queryHistory.py](clients/queryHistory.py): Queries all transactions present in the ledger for an id.
* [getConsumption.py](clients/getConsumption): ---

### Creating an Account

To create an account with geth on the Rinkeby test network we can execute the command:

```console
geth --rinkeby account new
```

We can see the accounts already created with:

```console
geth account list
```

To see accounts created on the Rinkeby network we can run:

```console
geth --rinkeby account list
```

To use a private account for this project you need to change the python clients to reference your account's private keys. By default they are under /home/username/.ethereum/rinkeby/keystore.