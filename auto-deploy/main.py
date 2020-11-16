import json
import sys
from web3 import Web3
from auto_deploy import deploy_contract
from Node import Node

node = Node(protocol='ws', address='wss://ropsten.infura.io/ws/v3/24fa53788c314fe5a1dafcd9cd37c3e9')
key = sys.argv[1]
contract = sys.argv[2]
arg_file = sys.argv[3]

contract = f'compiled/{contract}'

with open('args/' + arg_file) as f:
    args = f.read().split(',')

new_args = []

for arg in args:
    new_arg = arg
    if Web3.isAddress(arg):
        new_arg = Web3.toChecksumAddress(arg)
    if arg.isdigit():
        new_arg = int(arg)
    new_args.append(new_arg)


deploy_contract(node, key, contract, new_args)
