// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IBank.sol";

contract Admin{
    address public owner;

    constructor () {
        owner = msg.sender;
    }

    receive() external payable { }

    modifier onlyOwner(){
        if (msg.sender != owner) revert();
        _;
    }

    function withdraw() external onlyOwner{
        payable(owner).transfer(address(this).balance);
    } 

    function adminWithdraw(IBank bank) external onlyOwner{
        bank.withdraw();
    }
}