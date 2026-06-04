//this script uses the contract we had created (it's ABI and it's contract address) to call specific functions from the smart contract
const net = require('net');
const path = require('path');
const fs = require('fs-extra');
const Web3 = require('web3')

const web3dataJson = JSON.parse(fs.readFileSync('web3data.json','utf-8'))
const location = web3dataJson.location
//console.log('IPC file is located at:', location)
const password = web3dataJson.password
const web3 = new Web3(new Web3.providers.IpcProvider(location, net));

// read in the contracts
const contractJsonPath = path.resolve(__dirname, 'DoubleAuction.json');
const contractJson = JSON.parse(fs.readFileSync(contractJsonPath));
const contractAbi = contractJson.abi;
const contractByteCode = contractJson.bytecode

//in addition, we need the contract address
var data = fs.readFileSync('contAddressDoubleAuction.json','utf-8') //read the contAddress.json that got made when you ran deployDoubleAuction.js
contAddress = JSON.parse(data.toString()).address;
//console.log('the contract is at: ', contAddress)
const contractInstance = new web3.eth.Contract(contractAbi,contAddress)  //this is the javascript object that allows us to interact with the smart contract
//importantly: it has member functions with the same names as those in the smart contract


async function addBuyer(quantity, value, fromAddress)
{
    try {
        await contractInstance.methods.addBuyer(quantity, value).send({ from: fromAddress, gasLimit: '0xe00000' });
    } catch (e) {
        // if the bid is rejected, log only for debugging, as test script captures std out
        // console.error('bid rejected:', e.message);
    }
    //follows handout format
    console.log('submitted a buy bid of: (' + quantity + ', ' + value + ') from account: ' + fromAddress);
}


async function main()
{
    var args= process.argv;
    accountNo = args[4];
    quantity = args[2]; //quantity
    price = args[3]; //value
    
    var myAccount = "";
    await web3.eth.getAccounts().then(e => myAccount = e[accountNo]);
//    console.log("Your account is: ", myAccount)

    await web3.eth.personal.unlockAccount(myAccount, password, 60)
//    .then(console.log('Account unlocked!'));

   await addBuyer(quantity, price, myAccount);
}

main().then(() => process.exit(0));
