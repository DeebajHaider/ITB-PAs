// SPDX-License-Identifier: HF
pragma solidity ^0.8.1;

/*
Feel free to create your own functions and interact with them in JavaScript
DO NOT CHANGE THE FUNCTION DEFINITIONS OF ANY OF THE FUNCTIONS ALREADY DEFINED BELOW

THE ONLY FUNCTION YOU ARE ALLOWED THE CHANGE THE DEFINITION OF IS getHistory().
You will probably need to change that.
*/

contract DoubleAuction 
{
    struct Bid {
        address bidder;
        uint quantity;
        uint value;
    }

    Bid[] private buyers;        //current round buy bids
    Bid[] private sellers;       //current round sell bids

    uint private lastAuctionTime;

    // results of the last successful auction
    address[] private resultSellers;
    address[] private resultBuyers;
    uint[]    private resultQuantities;
    uint      private resultPrice;
    
    uint constant private maxSize = 20; //maximum number of bids
    uint constant private AuctionInterval = 30; //time in seconds. Contract shouldn't be called faster than this
   
    function addBuyer(uint quantity, uint price) public {
        if (alreadyBid(msg.sender)) return;                                  // one bid per EOA per round
        require(buyers.length + sellers.length < maxSize, "too many bids");
        require(msg.sender.balance >= quantity * price, "insufficient balance");
        buyers.push(Bid(msg.sender, quantity, price));
    }

    function addSeller(uint quantity, uint price) public {
        if (alreadyBid(msg.sender)) return;
        require(buyers.length + sellers.length < maxSize, "too many bids");
        sellers.push(Bid(msg.sender, quantity, price));                      // no balance check for sellers
    }

    function doubleAuction() public 
    {

        return;
    }

    function getResults() public view returns(uint returnedInteger)
    {
        return 0;
    }

    function sortBids(Bid[] memory arr, bool ascending) private pure returns (Bid[] memory) {
        for (uint i = 0; i < arr.length; i++) {
            for (uint j = 0; j + 1 < arr.length - i; j++) {
                bool outOfOrder = ascending
                    ? (arr[j].value > arr[j + 1].value)   // ascending
                    : (arr[j].value < arr[j + 1].value);  // descending
                if (outOfOrder) {
                    Bid memory tmp = arr[j];
                    arr[j] = arr[j + 1];
                    arr[j + 1] = tmp;
                }
            }
        }
        return arr;
    }

    //helper for addSeller and addBuyer, check if the bidder has already made a bid in the current round.
    function alreadyBid(address who) private view returns (bool) {
        for (uint i = 0; i < buyers.length; i++)  if (buyers[i].bidder == who)  return true;
        for (uint i = 0; i < sellers.length; i++) if (sellers[i].bidder == who) return true;
        return false;
    }
}

