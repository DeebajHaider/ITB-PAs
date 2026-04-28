// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

contract BankingSystem {

    // -------------------------
    // Data Structures
    // -------------------------

    // account structure for each individual that will interact with the bank
    struct Account {  
        string first_Name;
        string last_Name;
        uint principal_Loan; //principal amount of outstanding loan that hasnt been paid by customer
        uint interest_Loan; //outstanding interest amount on loan that hasnt been paid by customer
        uint balance; //customer account balance
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
        require((owner == tx.origin), "Only owner is allowed to call this function");
        _;
    }

    modifier notOwner() {
        // TODO: restrict owner from calling
        require((owner != tx.origin), "Owner is not allowed to call this function");
        _;
    }

    modifier hasAccount() {
        // TODO: ensure sender has an account
        require((userAccounts[tx.origin].exists) , "Account does not exist for this address");
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
        require((owner != tx.origin), "Error, Owner Prohibited");
        require((!userAccounts[tx.origin].exists), "Account already exists");
        userAccounts[tx.origin] = Account({
            first_Name: firstName,
            last_Name: lastName,
            principal_Loan: 0,
            interest_Loan: 0,
            balance: 0,
            exists: true
        });
        addressList.push(tx.origin);
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
        require((userAccounts[tx.origin].exists), "No Account");
        balance = userAccounts[tx.origin].balance;
        first_name = userAccounts[tx.origin].first_Name;
        last_name = userAccounts[tx.origin].last_Name;
        principal = userAccounts[tx.origin].principal_Loan;
        interest = userAccounts[tx.origin].interest_Loan;
    }

    function closeAccount() public {
        // TODO:
        // - prevent owner
        // - ensure account exists
        // - ensure no loan due
        // - ensure balance is zero
        // - delete account
        require((owner != tx.origin), "Error, Owner does not own an account");
        require((userAccounts[tx.origin].exists), "No Account Exists");
        require((userAccounts[tx.origin].principal_Loan == 0 && userAccounts[tx.origin].interest_Loan == 0), "Dues remaining, cannot close account before repayment");
        require((userAccounts[tx.origin].balance == 0), "Outstanding balance, withdraw it to close your account");
        //Make the ccount non existent, remove from address list.
        //shouldnt delete from userAccounts since all accounts alredy esist in it.
        userAccounts[tx.origin].exists = false;
    }

    // -------------------------
    // Deposits & Withdrawals
    // -------------------------
    function depositAmount() public payable {
        // TODO:
        // - ensure account exists
        // - enforce minimum deposit (>= 1 ether)
        // - update balance
        require((owner != tx.origin), "Error, Owner Prohibited");
        require((userAccounts[tx.origin].exists), "No Account");
        require((msg.value >= 1 ether), "Low Deposit");
        userAccounts[tx.origin].balance += msg.value;
    }

    function withDraw(uint withdrawalAmount) public {
        // TODO:
        // - prevent owner
        // - ensure account exists
        // - check sufficient balance
        // - deduct and transfer ETH
        require((owner != tx.origin), "Error, Owner Prohibited");
        require((userAccounts[tx.origin].exists), "No Account");
        require((withdrawalAmount <= userAccounts[tx.origin].balance), "Insufficient Funds");
        userAccounts[tx.origin].balance -= withdrawalAmount;
        (bool success, ) = payable(tx.origin).call{value: withdrawalAmount}("");
        require(success, "Withdrawal failed");

    }

    function TransferEth(address recipient, uint transferAmount) public {
        // TODO:
        // - prevent owner
        // - ensure sender account exists
        // - ensure recipient exists
        // - check balance
        // - transfer internally
        require((owner != tx.origin), "Error, Owner Prohibited");
        require((userAccounts[tx.origin].exists), "No Account");
        require((userAccounts[recipient].exists), "Recipient account does not exist");    
        require((transferAmount <= userAccounts[tx.origin].balance), "Insufficient Funds");
        userAccounts[tx.origin].balance -= transferAmount;
        userAccounts[recipient].balance += transferAmount;
    }

    // -------------------------
    // Loan Management
    // -------------------------
    function depositTopUp() public payable {
        // TODO:
        // - only owner
        // - increase loan funds
        require((owner == tx.origin), "Only Owner can call this function");
        loan_funds += msg.value;
    }

    function depositOperationalFunds() public payable {
        // TODO:
        // - only owner
        // - increase operational funds
        require((owner == tx.origin), "Only Owner can call this function");
        operational_funds += msg.value;
    }

    function TakeLoan(uint loanAmount) public {
        // TODO:
        // - prevent owner
        // - ensure account exists
        // - check loan funds availability
        // - enforce loan limit (based on balance)
        // - update principal loan
        // - transfer ETH
        require((owner != tx.origin), "Error, Owner Prohibited");
        require((userAccounts[tx.origin].exists), "No Account");
        require((loanAmount <= loan_funds), "Insufficient Loan Funds");
        require((loanAmount <= 2 * userAccounts[tx.origin].balance), "Loan Limit Exceeded");

        userAccounts[tx.origin].principal_Loan += loanAmount;
        loan_funds -= loanAmount;
        
        (bool success, ) = payable(tx.origin).call{value: loanAmount}("");
        require(success, "Transfer failed");
    }

    function InquireLoan() public view returns (
        uint principal,
        uint interest,
        uint total
    ) {
        // TODO:
        // - ensure account exists
        // - return loan info
        require((owner != tx.origin), "Error, Owner Prohibited");
        require((userAccounts[tx.origin].exists), "No Account");

        principal = userAccounts[tx.origin].principal_Loan;
        interest = userAccounts[tx.origin].interest_Loan;
        total = principal + interest;
    }

    function returnLoan() public payable {
        // TODO:
        // - ensure account exists
        // - ensure loan exists
        // - prevent overpayment
        // - pay interest first, then principal
        // - update operational_funds and loan_funds
        require((owner != tx.origin), "Error, Owner Prohibited");
        require((userAccounts[tx.origin].exists), "No Account");
        require((userAccounts[tx.origin].principal_Loan > 0), "No Loan");
        require((msg.value <= userAccounts[tx.origin].principal_Loan + userAccounts[tx.origin].interest_Loan), "Owed Amount Exceeded");

        if (msg.value <= userAccounts[tx.origin].interest_Loan){
            operational_funds += msg.value;
            userAccounts[tx.origin].interest_Loan -= msg.value;
        }
        else {
            uint temp = msg.value -userAccounts[tx.origin].interest_Loan;
            operational_funds += userAccounts[tx.origin].interest_Loan;
            userAccounts[tx.origin].interest_Loan = 0;
            userAccounts[tx.origin].principal_Loan -= temp;
            loan_funds += temp;
        }
    }

    // -------------------------
    // Interest Handling
    // -------------------------
    function setInterestRates(uint dep_interest_rate, uint loan_interest_rate) public {
        // TODO:
        // - only owner
        // - set depositInterestRate and loanInterestRate
        require((owner == tx.origin), "Only the owner can set interest rates");
        depositInterestRate = dep_interest_rate;
        loanInterestRate = loan_interest_rate;
    }

    function addDepositInterest() public {
        // TODO:
        // - only owner
        // - calculate total interest required
        // - ensure enough operational funds
        // - distribute interest to all users
        // - deduct from operational funds
        require((owner == tx.origin), "Only the owner can add interest to deposits");
        uint total_interest = 0;
        for (uint i = 0; i < addressList.length; i++) {
            uint interest = userAccounts[addressList[i]].balance * depositInterestRate / 100;
            userAccounts[addressList[i]].balance += interest;
            total_interest += interest;
            require(operational_funds   >= total_interest, "Not enough operational funds to pay interest");
        }
        operational_funds -= total_interest;
    }

    function addLoanInterest() public {
        // TODO:
        // - only owner
        // - loop through users
        // - add interest on principal loans
        require((owner == tx.origin), "Only the owner can add interest to loans");
        for (uint i = 0; i < addressList.length; i++) {
            uint interest = userAccounts[addressList[i]].principal_Loan * loanInterestRate / 100;
            userAccounts[addressList[i]].interest_Loan += interest;
        }
    }

    // -------------------------
    // Bank Info
    // -------------------------
    function AmountInBank() public view returns(uint) {
        // TODO:
        // return contract ETH balance
        return address(this).balance;
    }

    function DepositInterestRate() public view returns(uint) {
        // TODO:
        // return deposit interest rate
        return depositInterestRate;
    }

    function LoanInterestRate() public view returns(uint) {
        // TODO:
        // return loan interest rate
        return loanInterestRate;
    }

    function LoanFunds() public view returns(uint) {
        // TODO:
        // return loan funds
        return loan_funds;
    }

    function OperationalFunds() public view returns(uint) {
        // TODO:
        // return operational funds
        return operational_funds;
    }
}