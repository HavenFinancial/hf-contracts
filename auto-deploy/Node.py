import requests
from web3 import Web3
import os

class Node:

    ETHERSCAN_API_KEY = 'AD2PQ7ZYMTDAFAWSBCNMX1B47X33CC1T49'

    def __init__(self, protocol=None, address=None, ProviderInstance=None):
        if (protocol is None or address is None) and ProviderInstance is None:
            raise Exception(
                'Node creation must specify both protocol and address or a provider instance')
        if protocol == 'ipc':
            self.w3 = Web3(Web3.IPCProvider(address))
        elif protocol == 'http':
            self.w3 = Web3(Web3.HTTPProvider(address))
        elif protocol == 'ws':
            self.w3 = Web3(Web3.WebsocketProvider(address))
        elif ProviderInstance is not None:
            self.w3 = Web3(ProviderInstance)
        else:
            raise UnknownProtocolError(protocol)
        if not self.w3.isConnected():
            raise NodeConnectionError(protocol, address)

    def get_block(self, number='latest'):
        return self.w3.eth.getBlock(number)

    def get_blocks(self, min_block=0, max_block=None):
        blocks = []
        if max_block is None or max_block == 'latest':
            max_block = self.get_latest_block_number()
        for i in range(min_block, max_block):
            blocks.append(self.w3.eth.getBlock(i))
        return blocks

    def get_latest_block_number(self):
        return self.w3.eth.getBlock('latest')['number']

    def get_tx(self, tx_id):
        return self.w3.eth.getTransaction(tx_id)

    def get_txs(self, txs):
        tx_data = {}
        for tx in txs:
            tx_id = tx['hash']
            tx_data[tx_id] = self.w3.eth.getTransaction(tx_id)
        return tx_data

    def get_balance(self, address):
        return self.w3.eth.getBalance(address, 'latest')

    def get_contract_abi(self, address):
        response = requests.get(f'https://api.etherscan.io/api?module=contract&action=getabi&address={address}&apikey={Node.ETHERSCAN_API_KEY}')
        abi = response.json()['result']
        contract = self.w3.eth.contract(address=self.w3.toChecksumAddress(address), abi=abi)
        return contract

    def is_connected(self):
        return self.w3.isConnected()

    def send_tx(self, tx, key):
        signed_tx = self.w3.eth.signTransaction(tx, key)
        self.w3.eth.sendRawTransaction(signed_tx.rawTransaction)

    def generate_key(self):
        return Web3.keccak(os.urandom(4096))

class NodeConnectionError(Exception):

    def __init__(self, protocol, address):
        self.protocol = protocol
        self.address = address
        self.message = f'Unable to connect to {self.protocol} endpoint {self.address}'
        super().__init__(self.message)


class UnknownProtocolError(Exception):
    def __init__(self, protocol):
        self.protocol = protocol
        self.message = f'{protocol} is not a known Web3 provider protocol'
        super().__init__(self.message)