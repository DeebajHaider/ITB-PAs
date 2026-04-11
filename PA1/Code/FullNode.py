from logging.config import valid_ident
import time
import pickle
from Block import Block
import os
from hashing import *
import datetime
import json
from util import *
from network import Node
import sys
import copy
import shutil

"""
Establishing connection with backend
"""


class FullNode:
    def __init__(self, id):
        """
		DO NOT EDIT
		"""
        self.DIFFICULTY = 4  # Difficulty setting
        self.STUDENT_ID = id  # Do not edit, this is your student ID

        self.unconfirmed_transactions = []  # Raw 5 TXNs that you will get from the mempool
        self.all_unconfirmed_transactions = []  # all Raw unconfirmed txns from mempool
        self.valid_but_unconfirmed_transactions = {}
        self.valid_chain, self.confirmed_transactions = load_valid_chain()  # Your valid chain, all the TXNs in that valid chain
        self.corrupt_transactions = []  # Initialize known invalid TXNs. To be appended to (by you, later). These are transactions whose signatures don't match or their output > input
        self.UTXO_Database_Pending = {}  # This is a temporary UTXO database you may use.
        self.UTXO_Database = {}
        self.balances = {}
        self.processed_transactions = set()
        self.current_block = None

    def last_block(self):
        """
		DO NOT EDIT
		returns last block of the valid chain loaded in memory
		"""
        self.valid_chain.sort(key=self.sortHelper)
        return self.valid_chain[-1]

    ## PART ONE - UTXO Database Construction##

    ## Add code for part 1 here (You can make as many helper function you want)
    def verifyTransaction(self, Tx):
        #print(f"COINBASE value: {Tx['COINBASE']}, type: {type(Tx['COINBASE'])}")
        # verfy each input transaction signature
        for item in Tx['inputs']:
            prevTxnId     = item[0]
            output_number = item[1]
            signature     = item[2]
            PubKey        = item[3]
            
            #verify if signature is vaid for each input
            currentHash = calculateHash(stringifyTransactionExcludeSig(Tx))
            finalString = str(prevTxnId) + ":" + str(currentHash)
            
            if not VerifySignature(finalString, signature, PubKey):
                self.corrupt_transactions.append(Tx)
                return False
            
            #check if pubkeyhash of parent is same as pubkyhash of this one
            if (prevTxnId, output_number) in self.UTXO_Database_Pending:
                stored_pubkey_hash = self.UTXO_Database_Pending[(prevTxnId, output_number)][1]
                if stored_pubkey_hash != hashPubKey(PubKey):
                    self.corrupt_transactions.append(Tx)
                    return False
            
            
        #validate if the input is transaction is actually in the UTXO database, don't need to if coinbase
        database_backup = copy.deepcopy(self.UTXO_Database_Pending)
        inputSum = 0
        if Tx['COINBASE'] is False:
            for item in Tx['inputs']:
                prevTxnId     = item[0]
                output_number = item[1]
                if (prevTxnId, output_number) not in self.UTXO_Database_Pending:
                    self.UTXO_Database_Pending = database_backup
                    return False
                else:
                    inputSum += self.UTXO_Database_Pending[(prevTxnId, output_number)][0]
                    del self.UTXO_Database_Pending[(prevTxnId, output_number)]
        else:
            #print("This is a coinbase transaction")
            #5^9 satoshis
            inputSum = 5000000000
            if Tx['id'] in self.UTXO_Database_Pending:
                self.UTXO_Database_Pending = database_backup
                return False
            self.UTXO_Database_Pending[Tx['id']] = True  # duplicate prevention marker
                
        #calculate value of outputs
        outputSum = 0
        for item in Tx['outputs']:
            outputSum += item[0]
                
        #vaidate if value of inputs is greater than value of outputs
        if (inputSum < outputSum):
            self.corrupt_transactions.append(Tx)
            self.UTXO_Database_Pending = database_backup
            return False
        
        #if valid, then add output transaction to UTXO database
        for i, output in enumerate(Tx['outputs']):
            self.UTXO_Database_Pending[(Tx['id'], i)] = (output[0], output[1])

        self.processed_transactions.add(Tx['id'])
        return True
            
            

    def findValidButUnconfirmedTransactions(self):
        # find 5 valid transactions that are NOT in a block yet
        self.UTXO_Database_Pending = copy.deepcopy(self.UTXO_Database)
        self.valid_but_unconfirmed_transactions = {}
        validTx = 0
        for tx in self.unconfirmed_transactions:
            if(self.verifyTransaction(tx)):
                validTx += 1
                self.valid_but_unconfirmed_transactions[tx['id']] = tx
                if validTx == 5:
                    break
        return self.valid_but_unconfirmed_transactions
                

	## PART TWO - Mining and Proof-Of-Work ##
	# Mine Blocks -- skip genesis block
    # Suggested steps:
    # 1. Update UTXO if update==True
    # 2. Copy to pending
    # 3. Collect valid transactions
    # 4. Create block
    # 5. Run proof_of_work
    # 6. Append and save block
    # 7. Update UTXO
    def mine(self, startingNonce=0, update=True):
        """
        Mines a new block containing valid unconfirmed transactions.

        Because proof_of_work may exit early without finding a valid hash,
        mine() is designed to be called repeatedly until it succeeds.
        The calling loop in main.py already handles this — study it before
        implementing this function, as your return values must match what
        it expects.

        Parameters:
            startingNonce (int): The nonce value to start searching from.
                                 Passed in by main.py — 0 on the first call,
                                 and whatever this function last returned on
                                 subsequent calls.
            update (bool): Whether to rebuild the UTXO database and collect
                           fresh transactions. Passed in by main.py — True on
                           the first call only, False on resume calls.

        Returns:
            0              if a block was successfully mined.
            nonce (int)    if proof_of_work exited early; main.py will pass
                           this back in as startingNonce on the next call.

        You should check what proof_of_work returns and handle both cases.
        """
        # Save block to physical memory here.
        # Syntax to store block: save_object(new_block,"valid_chain/block{}.block".format(new_block.index))
        if update == True:
            self.update_UTXO()
            self.findValidButUnconfirmedTransactions()
            self.current_block = Block(0, [], "", "", "")
            self.current_block.index = self.last_block().index + 1
            self.current_block.transactions = list(self.valid_but_unconfirmed_transactions.values())
            self.current_block.time_stamp = str(datetime.datetime.now().strftime("%d-%m-%Y (%H:%M:%S)"))
            self.current_block.previous_hash = self.computeBlockHash(self.last_block())
            self.current_block.nonce = startingNonce
            self.current_block.miner = self.STUDENT_ID
        
        block_hash, nonce = self.proof_of_work(self.current_block)
        if block_hash == 0:
            return nonce
        else:
            self.valid_chain.append(self.current_block)
            save_object(self.current_block, "valid_chain/block{}.block".format(self.current_block.index))
            return 0
            

    def proof_of_work(self, block):
        """
        Performs Proof-Of-Work on the given block by iterating the nonce until
        the block hash meets the difficulty condition (self.DIFFICULTY leading zeros)
        AND the nonce is a multiple of 10.

        To avoid blocking the program indefinitely, this function exits early
        after a fixed number of iterations if no valid hash is found yet.
        In that case, return (0, block.nonce) so the caller knows to resume
        from this nonce in the next call.

        If a valid hash IS found, return (computed_hash, block.nonce).

        Returns: (hash_string, nonce)  on success
                 (0, nonce)            on early exit (limit reached, keep trying)
        """
        #just for safety, practically the nonce should always be a multiple of 10
        #since we start from 0 and increment with 10
        start = block.nonce
        if start % 10 != 0:
            start = start + (10 - start % 10)
        
        for nonce in range(start, start + 50000, 10):
            block.nonce = nonce
            block_hash = self.computeBlockHash(block)
            if block_hash.startswith('0' * self.DIFFICULTY):
                return block_hash, nonce
        return 0, block.nonce

    def computeBlockHash(self, block):  # Compute the aggregate transaction hash.
        block_string = json.dumps(block.__dict__, sort_keys=True)
        return sha256(block_string.encode()).hexdigest()

    def sortHelper(self, block):
        return block.index

    def sortHelperNumber(self, Tx):
        return Tx['number']

    def update_UTXO(self, till=-1):
        self.UTXO_Database_Pending = {}
        for block in self.valid_chain:
            if block.index == 0:
                continue
            for tx in block.transactions:
                self.verifyTransaction(tx)
        self.UTXO_Database = copy.deepcopy(self.UTXO_Database_Pending)
        return 

    def showAccounts(self):
        #print(self.UTXO_Database_Pending)
        for key, value in self.balances.items():
            self.balances[key] = 0
        for key, val in self.UTXO_Database_Pending.items():
            if val is True:  # skip coinbase duplicate markers
                continue
            value, pubKeyHash = val[0], val[1]
            if pubKeyHash not in self.balances:
                self.balances[pubKeyHash] = 0
            self.balances[pubKeyHash] += value
        #for key, val in self.balances.items():
            #print(f'Account {key} has balance {val}')
        return self.balances

    ## PART TWO ##

    def validate_pending_chains(self):
        """
        DO NOT EDIT
        This method loads pending chains from the 'pending_chains' folder.
        It then calls verify_chain method on each chain performing a series of validity checks
        if all the tests pass, it replaces the current valid chain with pending chain and saves it in valid chain folder.
        """

        Found = False

        self.valid_chain, self.confirmed_transactions = load_valid_chain()
        MAIN_DIR = "pending_chains"
        subdirectories = [name for name in os.listdir(MAIN_DIR) if os.path.isdir(os.path.join(MAIN_DIR, name))]
        if not subdirectories:
            print("No pending chains found to validate.")
            return False
        for directory in subdirectories:
            temp_chain = []
            DIR = MAIN_DIR + "/" + directory
            block_indexes = [name for name in os.listdir(DIR) if os.path.isfile(os.path.join(DIR, name))]
            block_indexes.sort()
            for block_index in block_indexes:
                try:
                    with open(DIR + '/{}'.format(block_index), 'rb') as inp:
                        block = pickle.load(inp)
                        temp_chain.append(block)
                except:
                    pass
            last_block_index = temp_chain[0].index - 1
            if last_block_index >= len(self.valid_chain):
                print(f' last_block_index {last_block_index} >= len(self.valid_chain) {len(self.valid_chain)} ?')
                print("Rejected chain from", directory)
                shutil.rmtree(DIR, ignore_errors=True)
                continue

            last_block_hash = self.computeBlockHash(self.valid_chain[last_block_index])
            current_longest = self.valid_chain[:last_block_index + 1] + temp_chain
            if (self.verify_chain(current_longest, temp_chain, last_block_hash)):
                print("Replaced valid chain with chain from", directory)
                self.valid_chain = current_longest
                save_chain(current_longest)
                self.valid_chain, self.confirmed_transactions = load_valid_chain()
                Found = True
            else:
                print("Rejected chain from", directory)
            shutil.rmtree(DIR, ignore_errors=True)
        if not Found:
            print("No pending chain replaced your current valid chain.")
        return Found

    def verify_chain(self, current_longest, temp_chain, last_block_hash):
        print(f"verify_chain called with {len(temp_chain)} temp blocks, {len(current_longest)} total")
        if current_longest[-1].index <= self.valid_chain[-1].index:
            print("FAIL: incoming chain is not longer")
            return False
        target = '0' * self.DIFFICULTY
        temp_start_index = temp_chain[0].index

        current_longest.sort(key=lambda b: b.index)
        temp_chain.sort(key=lambda b: b.index)

        prev_hash = last_block_hash
        prev_index = temp_start_index - 1

        for block in temp_chain:
            if block.index != prev_index + 1:
                print(f"FAIL index at block {block.index}")
                return False
            if block.previous_hash != prev_hash:
                print(f"FAIL hash linkage at block {block.index}")
                return False
            block_hash = self.computeBlockHash(block)
            if block_hash[:self.DIFFICULTY] != target:
                print(f"FAIL difficulty at block {block.index}, hash: {block_hash[:10]}")
                return False
            prev_hash = block_hash
            prev_index = block.index

        self.UTXO_Database_Pending = {}
        for block in current_longest:
            if block.index == 0:
                continue
            if block.index >= temp_start_index:
                break
            for Tx in block.transactions:
                self.verifyTransaction(Tx)

        for block in temp_chain:
            block_utxo_snapshot = copy.deepcopy(self.UTXO_Database_Pending)
            for Tx in block.transactions:
                if not self.verifyTransaction(Tx):
                    print(f"FAIL transaction {Tx['id']} in block {block.index}")
                    self.UTXO_Database_Pending = block_utxo_snapshot
                    return False

        print("PASSED verify_chain")
        return True


    def print_chain(self):
        """
		DO NOT EDIT
		Prints the current valid chain in the terminal.
		"""
        self.valid_chain, self.confirmed_transactions = load_valid_chain()

        self.valid_chain.sort(key=self.sortHelper)

        for block in self.valid_chain:
            print("***************************")
            print(f"Block index # {block.index}")

            for trans in block.transactions:
                # if not block.index: #This is because the first block is hard coded and may have a different format
                # 	print("Sender: {}".format(trans["sender"]['key']) )
                # 	print("Receiver: {}".format(trans['receiver']['key']))
                # 	print("Token: {}".format(trans["signature_token"]) )
                # 	print("UTXO input: {}".format(trans["UTXO_input"]))
                # 	print("Sender received: {}".format(trans["value_sender"]))
                # 	print("Receiver received: {}".format(trans["value_receiver"]))
                # 	print("ID: {}".format(trans["id"]))
                if block.index:
                    print(f'Transaction number {trans["number"]} with hash {trans["id"]}')

            print("---------------------------")

            print("nonce: {}".format(block.nonce))
            print("previous_hash: {}".format(block.previous_hash))
            print('hash: {}'.format(self.computeBlockHash(block)))
            print('Miner: {}'.format(block.miner))
            print("***************************")
            print("")
