from web3 import Web3
import time
import json
from web3.middleware import geth_poa_middleware
from web3.middleware import construct_sign_and_send_raw_middleware
from eth_account import Account
from tornado.platform.asyncio import AnyThreadEventLoopPolicy
from waitress import serve
import asyncio
from flask import *
import sys
sys.path.insert(0, "..")

'''Necessary to run Flask'''
app = Flask(__name__)

'''To solve a problem with asyncio'''
asyncio.set_event_loop_policy(AnyThreadEventLoopPolicy())

@app.route('/', methods=['POST'])
def insertBlockchain():

    '''Define infrastructure and IPCProvider'''
    infra_url = "/home/ison/.ethereum/rinkeby/geth.ipc"
    web3 = Web3(Web3.IPCProvider(infra_url))

    '''Define middleware for authentication'''
    web3.middleware_onion.inject(geth_poa_middleware, layer=0)

    '''Load contract interface'''
    abi_file = open('../compiled/EthHermes.abi', 'r')
    contract_abi = json.loads(abi_file.read())
    abi_file.close()

    '''Define account address'''
    myAccount = "0x91223d6543Be90f760CCd3dd03df30A60ed758D4"

    '''Set myAccount as default account'''
    web3.eth.defaultAccount = myAccount

    '''Define contract address'''
    contract_address = "0x6dC5d7e786131040508aE0CFf764ACdfC4839D09"

    '''Load private key'''
    private_key = None
    with open('../keys/91223d6543Be90f760CCd3dd03df30A60ed758D4') as keyfile:
        encrypted_key = keyfile.read()
        private_key = web3.eth.account.decrypt(encrypted_key, 'inmetroeth')

    '''Set private key for middleware'''
    web3.middleware_onion.add(construct_sign_and_send_raw_middleware(private_key))

    '''Receive the data'''
    data = json.loads(request.data)

    '''Instantiate a contract using the abi and contract address'''
    contract = web3.eth.contract(address = contract_address, abi = contract_abi)

    '''Createa transaction body'''
    tx = {
        'from': myAccount,
        'gas': 4700000,
        'gasPrice': web3.eth.gasPrice
    }

    '''Send transaction'''
    tx_hash = contract.functions.store(int(data['id']),
                                       data['sensor'],
                                       float.as_integer_ratio(data['value']),
                                       float.as_integer_ratio(data['Timestamp']),
                                       data['location'],
                                       data['physicalQuantity']).transact(tx)

    '''Wait for receipt'''
    tx_receipt = web3.eth.waitForTransactionReceipt(tx_hash)

    '''If the transaction was submitted returns "ok"'''
    if(tx_receipt is not None):
        '''Print the transaction hash'''
        print(tx_hash.hex())
        return "Ok"
    

'''Defines the the host and port of communication'''
serve(app, host='0.0.0.0', port=9095)

if __name__ == '__main__':
    insertBlockchain()
