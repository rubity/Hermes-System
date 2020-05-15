from web3 import Web3
import time
import json
import sys
sys.path.insert(0, "..")

def queryHistory():

    '''Define infrastructure and IPCProvider'''
    infra_url = "/home/ison/.ethereum/rinkeby/geth.ipc"
    web3 = Web3(Web3.IPCProvider(infra_url))

    '''Load contract interface'''
    abi_file = open('../compiled/EthHermes.abi', 'r')
    contract_abi = json.loads(abi_file.read())
    abi_file.close()

    '''Define account address'''
    myAccount = "0x91223d6543Be90f760CCd3dd03df30A60ed758D4"

    if(len(sys.argv) > 1):
        '''get the meter ID'''
        meter_id = int(sys.argv[1])
    else:
        meter_id = 0

    '''Set myAccount as default account'''
    web3.eth.defaultAccount = myAccount

    '''Define contract address'''
    contract_address = "0x6dC5d7e786131040508aE0CFf764ACdfC4839D09"

    '''Instantiate a contract using the abi and contract address'''
    contract = web3.eth.contract(address = contract_address, abi = contract_abi)

    '''Call read function for all values'''
    block_number = contract.functions.getBlock().call()
    last_block_number = contract.functions.getLastBlock().call()
    while(block_number != last_block_number):
        print(contract.functions.read(meter_id).call(block_identifier=block_number))
        block_number = last_block_number
        last_block_number = contract.functions.getLastBlock().call(block_identifier=last_block_number)

if __name__ == '__main__':
    queryHistory()
