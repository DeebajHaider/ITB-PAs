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
    uint constant private maxSize = 20; //maximum number of bids
    uint constant private AuctionInterval = 30; //time in seconds. Contract shouldn't be called faster than this

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

    function doubleAuction() public {
        // check time from block timestamp
        require(block.timestamp >= lastAuctionTime + AuctionInterval, "auction interval not passed");

        // step 1: sort the bids
        Bid[] memory s = sortBids(sellers, true);   // ascending  → s[0] cheapest
        Bid[] memory b = sortBids(buyers, false);   // descending → b[0] highest

        // step 2: find the smaller of the two lengths, we'll only iterate till then
        uint n = s.length < b.length ? s.length : b.length;
        // matches is essentially the same as k+1
        uint matches = 0;
        for (uint i = 0; i < n; i++) {
            if (b[i].value >= s[i].value) matches++;
            else break;
        }

        // rebuild results
        delete resultSellers;
        delete resultBuyers;
        delete resultQuantities;
        resultPrice = 0;

        //step 3
        if (matches > 0) {
            //(s_k+b_k)/2
            resultPrice = (s[matches - 1].value + b[matches - 1].value) / 2;
            //up till k, we have matches, so we pick the lower quanity between the two, and add the results.
            for (uint i = 0; i < matches; i++) {
                resultSellers.push(s[i].bidder);
                resultBuyers.push(b[i].bidder);
                uint q = s[i].quantity < b[i].quantity ? s[i].quantity : b[i].quantity;
                resultQuantities.push(q);
            }
        }

        // clear bids
        delete buyers;
        delete sellers;

        // reset the timer
        // uses block.timestamp because a contract doesnt have eccess to an external clock
        lastAuctionTime = block.timestamp;
    }

    function getResults() public view returns (
        address[] memory matchedSellers,
        address[] memory matchedBuyers,
        uint price,
        uint[] memory quantities
    ) {
        return (resultSellers, resultBuyers, resultPrice, resultQuantities);
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

