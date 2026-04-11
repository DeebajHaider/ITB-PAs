# Programming Assignment 1: Simulating a Blockchain Node

**Course:** CSE-355: Introduction to Blockchain  
**Institution:** IBA Karachi  
**Deadline:** 11:55 PM on 19th April 2026  
**Total Marks:** 60

## Assignment Overview

This assignment enhances understanding of Bitcoin's protocol for mining and validating chains. You will run your own blockchain node, validate transactions, mine blocks, and share your chain with peers—mirroring the structure and protocols of Bitcoin.

**Based on original work by:** Zaeem Mohtashim Khan and Huzaifa Ahmad (LUMS)

## Course Rules

- **Discussion Policy:** You may discuss issues and confusions with course staff only
- **Plagiarism Policy:** Strict plagiarism policy in effect
- **Sharing Policy:** Share blockchains, not code

## Assignment Structure

### Part 1: UTXO Database Construction (40 Marks)

This section focuses on understanding how transactions are verified and how double-spending is avoided in the Bitcoin blockchain.

**Key Components:**
- Transaction structure and fields (id, COINBASE, inputs, outputs, number)
- Transaction validity verification (signature verification and UTXO tracking)
- UTXO Database construction and maintenance
- User balance queries

**Functions to Implement:**
- `verifyTransaction()`: Checks if a transaction is not corrupt and is valid
- `showAccounts()`: Displays user balances

**Core Concepts:**
- Signature verification using public keys
- Input/Output management
- Preventing double-spending through UTXO tracking
- Coinbase transactions (block rewards)

### Part 2: Mining and Proof-of-Work (20 Marks)

This section involves creating blocks filled with valid transactions to build a blockchain and verifying peer chains.

**Key Functions to Implement:**
- `update_UTXO()`: Updates UTXO database from valid chain
- `findValidButUnconfirmedTransactions()`: Collects valid unconfirmed transactions from mempool
- `mine()`: Creates and mines blocks
- `proof_of_work()`: Implements Proof-of-Work algorithm with early exit

**Key Concepts:**
- Block structure and mining
- Nonce iteration (must be multiples of 10)
- Difficulty-based leading zeros criterion
- Chain verification
- Resumable mining with early exit

## Project Structure

```
PA1/
├── Code/
│   ├── main.py              # Interactive menu (DO NOT EDIT)
│   ├── FullNode.py          # Main file to edit (node implementation)
│   ├── Block.py             # Block class (DO NOT EDIT)
│   ├── Transaction.py       # Transaction structure (DO NOT EDIT)
│   ├── hashing.py           # Hashing utilities (DO NOT EDIT)
│   ├── network.py           # Network communication (DO NOT EDIT)
│   ├── util.py              # Utility functions
│   ├── testCode.py          # Test cases
│   ├── mempool/             # Unconfirmed transactions
│   ├── pending_chains/      # Candidate blockchain chains
│   ├── valid_chain/         # Validated blockchain storage
│   └── .gitignore           # Git ignore file
├── CSE355_Spring26_PA1.pdf  # Assignment specification
└── README.md                # This file
```

## Getting Started

### Prerequisites

- Python 3.x
- Understanding of blockchain concepts from the course

### Running the Assignment

First-time execution initializes the setup with the backend and loads transactions (takes ~5 minutes):

```bash
cd PA1/Code/
python3 main.py
```

A `>` prompt indicates the system is ready for commands.

### Available Commands

- `mine`: Begin mining blocks
- `send state`: Broadcast your blockchain to peers
- `ra`: Request all chains from other students
- `rl`: Request the longest chain available
- Custom commands as per the interactive menu

## Important Notes

### Allowed Edits

- **Only edit:** `FullNode.py`
- **Within FullNode.py:** DO NOT remove skeleton code or redefine constants
- **Allowed use:** Utility functions from `util.py`

### Key Implementation Details

1. **Transaction Verification:**
   - Verify signature integrity for all inputs
   - Ensure no reuse of already-spent outputs
   - Preserve total value (inputs ≥ outputs)

2. **UTXO Database:**
   - Recommended to use Python dictionary
   - Key: Could be transaction ID or owner identifier
   - Value: Output details (owner, transaction ID, value)

3. **Mining:**
   - Proof-of-Work: Find nonce where block hash has DIFFICULTY leading zeros
   - Nonce constraint: Must be a multiple of 10
   - Early exit: Stop after 5000 iterations
   - Resumable: Support continuing mining from previous state

4. **Honest Miner:**
   - The TA ("aqib 29008") runs 24/7 to facilitate merging of valid blocks
   - Helps verify successful block addition to blockchain

## Documentation Files

All transaction and block fields are well-documented in:
- `Transaction.py`: Transaction structure
- `Block.py`: Block structure
- `hashing.py`: Hash verification functions

## Testing

Run test cases with:

```bash
python3 testCode.py
```

## Key Concepts Review

- **Signatures:** Verify transaction authenticity using public/private keys
- **UTXOs:** Track unspent transaction outputs to prevent double-spending
- **Coinbase:** The 5e9 satoshi block reward for miners
- **Proof-of-Work:** Computational puzzle solving with difficulty adjustment
- **Chain Verification:** Validate block indexing, hashing, and transactions

## Troubleshooting

- **Initialization takes long:** This is normal on first run; backend setup is CPU-intensive
- **Mining is slow:** Adjust `DIFFICULTY` for testing; remember nonce must be divisible by 10
- **Transaction rejected:** Verify UTXO state and signature validity

---

**Note:** Your submission will be tested against a network of peer submissions. Ensure your node properly validates transactions and mines correctly to maximize your score.
