from web3 import Web3
import time
import json


def deploy():

    '''Define infrastructure and IPCProvider'''
    infra_url = "/home/ison/.ethereum/rinkeby/geth.ipc"
    web3 = Web3(Web3.IPCProvider(infra_url))

    '''Load contract interface and bytecode'''
    abi_file = open('../compiled/EthHermes.abi', 'r')
    bytecode_file = open('../compiled/EthHermes.bin', 'r')

    contract_abi = json.loads(abi_file.read())
    contract_bytecode = ''.join(['0x', bytecode_file.read()])

    abi_file.close()
    bytecode_file.close()

    '''Define account address'''
    myAccount = "0x91223d6543Be90f760CCd3dd03df30A60ed758D4"

    '''Set myAccount as default account'''
    web3.eth.defaultAccount = myAccount

    print('Your contract abi:\n')
    print(json.dumps(contract_abi, indent=4, sort_keys=True))
    print('Your contract bytecode:\n')
    print(contract_bytecode)

    '''Load private key'''
    with open('../keys/91223d6543Be90f760CCd3dd03df30A60ed758D4') as keyfile:
        encrypted_key = keyfile.read()
        private_key = web3.eth.account.decrypt(encrypted_key, 'inmetroeth')

    '''Create a contract object using the abi and contract bytecode'''
    contract = web3.eth.contract(abi = contract_abi, bytecode = contract_bytecode)

    '''Define the raw transaction details'''
    tx = {
        'nonce': web3.eth.getTransactionCount(myAccount),
        'from': myAccount,
        'data': contract_bytecode,
        'gas': 4700000,
        'gasPrice': web3.eth.gasPrice
    }
    
    '''Signs raw transaction with private key'''
    signed_tx = web3.eth.account.signTransaction(tx, private_key)
    '''Send raw transaction'''
    tx_hash = web3.eth.sendRawTransaction(signed_tx.rawTransaction)
    tx_receipt = web3.eth.waitForTransactionReceipt(tx_hash)

    print(tx_receipt)
    if(tx_hash is not None):#adicionar verificação de status
        print("Contract deployed!")
        print(web3.toHex(tx_hash))
    else:
        print("Error, contract not deployed")

if __name__ == '__main__':
    deploy()
