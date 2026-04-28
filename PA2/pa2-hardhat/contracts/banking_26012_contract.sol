// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

contract BankingSystem {

    // -------------------------
    // Data Structures
    // -------------------------

    // account structure for each individual that will interact with the bank
    struct Account {  
        string firstName;
        string lastName;
        uint principalLoan;
        uint interestLoan;
        uint balance;
        bool exists; // IMPORTANT: track if account exists
    }

    address private owner; //represents the owner

    address[] public addressList;  //list of all customer addresses
    //a hashmap linking key address to account object
    //by default all the keys already exist with zeroed out data, this is why we use the exists variable
    mapping(address => Account) public userAccounts; 

    uint private depositInterestRate; //inteerst rate (%) applied ot customer deposits
    uint private loan_funds; //loan reserve maintained by the bank, deposited by the owner. If it is 0, loans cannot be given out
    uint private loanInterestRate; //interest rate (%) applied to customer loans
    uint private operational_funds; //funds maintained by the bank to maintain internal expenses. deposited by owner, used to pay interest on depostits.

    // -------------------------
    // Constructor
    // -------------------------
    constructor() {
        // - set contract owner
        // - initialize interest rates and funds to 0
        owner = tx.origin;
        depositInterestRate = 0;
        loanInterestRate = 0;
        loan_funds = 0;
        operational_funds = 0;
    }

    // -------------------------
    // Modifiers
    // -------------------------
    modifier onlyOwner() {
        // TODO: allow only owner
        require((owner == tx.origin), "Only owner is allowed to call this function")
        _;
    }

    modifier notOwner() {
        // TODO: restrict owner from calling
        require((owner != tx.origin), "Owner is not allowed to call this function")
        _;
    }

    modifier hasAccount() {
        // TODO: ensure sender has an account
        require((userAccounts[tx.origin].exists) , "Account does not exist for this address")
        _;
    }

    // -------------------------
    // Account Management
    // -------------------------
    function openAccount(string memory firstName, string memory lastName) public {
        // TODO:
        // - prevent owner from opening account
        // - ensure account doesn't already exist
        // - create account
        // - push address to addressList
    }

    function getDetails() public view returns (
        uint balance,
        string memory first_name,
        string memory last_name,
        uint principal,
        uint interest
    ) {
        // TODO:
        // - ensure account exists
        // - return account fields
    }

    function closeAccount() public {
        // TODO:
        // - prevent owner
        // - ensure account exists
        // - ensure no loan due
        // - ensure balance is zero
        // - delete account
    }

    // -------------------------
    // Deposits & Withdrawals
    // -------------------------
    function depositAmount() public payable {
        // TODO:
        // - ensure account exists
        // - enforce minimum deposit (>= 1 ether)
        // - update balance
    }

    function withDraw(uint withdrawalAmount) public {
        // TODO:
        // - prevent owner
        // - ensure account exists
        // - check sufficient balance
        // - deduct and transfer ETH
    }

    function TransferEth(address recipient, uint transferAmount) public {
        // TODO:
        // - prevent owner
        // - ensure sender account exists
        // - ensure recipient exists
        // - check balance
        // - transfer internally
    }

    // -------------------------
    // Loan Management
    // -------------------------
    function depositTopUp() public payable {
        // TODO:
        // - only owner
        // - increase loan funds
    }

    function depositOperationalFunds() public payable {
        // TODO:
        // - only owner
        // - increase operational funds
    }

    function TakeLoan(uint loanAmount) public {
        // TODO:
        // - prevent owner
        // - ensure account exists
        // - check loan funds availability
        // - enforce loan limit (based on balance)
        // - update principal loan
        // - transfer ETH
    }

    function InquireLoan() public view returns (
        uint principal,
        uint interest,
        uint total
    ) {
        // TODO:
        // - ensure account exists
        // - return loan info
    }

    function returnLoan() public payable {
        // TODO:
        // - ensure account exists
        // - ensure loan exists
        // - prevent overpayment
        // - pay interest first, then principal
        // - update operational_funds and loan_funds
    }

    // -------------------------
    // Interest Handling
    // -------------------------
    function setInterestRates(uint dep_interest_rate, uint loan_interest_rate) public {
        // TODO:
        // - only owner
        // - set depositInterestRate and loanInterestRate
    }

    function addDepositInterest() public {
        // TODO:
        // - only owner
        // - calculate total interest required
        // - ensure enough operational funds
        // - distribute interest to all users
        // - deduct from operational funds
    }

    function addLoanInterest() public {
        // TODO:
        // - only owner
        // - loop through users
        // - add interest on principal loans
    }

    // -------------------------
    // Bank Info
    // -------------------------
    function AmountInBank() public view returns(uint) {
        // TODO:
        // return contract ETH balance
    }

    function DepositInterestRate() public view returns(uint) {
        // TODO:
        // return deposit interest rate
    }

    function LoanInterestRate() public view returns(uint) {
        // TODO:
        // return loan interest rate
    }

    function LoanFunds() public view returns(uint) {
        // TODO:
        // return loan funds
    }

    function OperationalFunds() public view returns(uint) {
        // TODO:
        // return operational funds
    }
}