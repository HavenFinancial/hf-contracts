from web3 import Web3
import json
import requests

def deploy_contract(node, private_key, contract, args):
    w3 = node.w3
    try:
        with open(contract) as f:
            token = 'xoxb-1439997501442-1504086815714-lZoWyzAufclMkfiMIElUlVSM'
            url = "https://slack.com/api/chat.postMessage"
            file_content = f.read()
            compiled_sol = json.loads(file_content)
            sender_account = w3.eth.account.privateKeyToAccount(private_key)
            bytecode = compiled_sol['bytecode']
            abi = compiled_sol['abi']
            new_contract = w3.eth.contract(abi=abi, bytecode=bytecode)
            transaction = new_contract.constructor(*args).buildTransaction()
            transaction['nonce'] = w3.eth.getTransactionCount(sender_account.address)
            signed_tx = w3.eth.account.signTransaction(transaction, sender_account.privateKey)
            tx_id = w3.eth.sendRawTransaction(signed_tx.rawTransaction)
            tx_receipt = w3.eth.waitForTransactionReceipt(tx_id)
            print(f'New {contract} has been deployed to {tx_receipt.contractAddress}')
            headers = {
                "Content-type": "application/json; charset=UTF-8",
                "Authorization": f'Bearer {token}'
            }
            contract_name = contract.split(".")[0].split("/")[1]
            params = {
                "channel": "#alerts",
                "text": f'New {contract_name} contract has been deployed to <https://ropsten.etherscan.io/address/{tx_receipt.contractAddress}|{tx_receipt.contractAddress}>'
            }

            response = requests.post(url, headers=headers, json=params)
            print(response.status_code)
            print(response.content)

    except Exception as e:
        print("Failed to deploy contract")
        print(e)
        exit(1)




