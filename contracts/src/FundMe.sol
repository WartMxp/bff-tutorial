// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "./PriceConverter.sol";

error NotOwner();

contract FundMe {
    using PriceConverter for uint256;
    uint256 public constant minimumUsd = 1 * 1e18;

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;
    
    address public immutable i_owner;

    constructor() {
        i_owner = msg.sender;
    }

    modifier onlyOwner {
        if(msg.sender != i_owner) {
            revert NotOwner();
        }
        _;
    }

    function fund() public payable {
        
        msg.value.getConversionRate();
        require(msg.value.getConversionRate() > minimumUsd, "Didn't send enough.");
        // revert == try/deflate
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = msg.value;

    }

    function withdraw() public onlyOwner { //mn

        require(msg.sender == i_owner, "Sender is not i_owner.");

        for(uint256 funderIndex = 0; funderIndex < funders.length;funderIndex ++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        funders = new address[](0);
        // payable(msg.sender).transfer(address(this).balance); (try/deflate, send)
        (bool callSuccess, ) = payable(msg.sender).call {
            value: address(this).balance
        } ("");
        require(callSuccess, "Call failed");
    }
    
}