// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./Bank.sol";

contract BigBank is Bank {

    error ValueIsTooSmall(address sender, uint256 value);

    modifier preCheck() {
        if(msg.value<0.01 ether) revert ValueIsTooSmall(msg.sender, msg.value);
        _;
    }

    receive() external payable override preCheck{ 
        deposits[msg.sender] += msg.value;
        _updateTopDepositors(msg.sender);
    }

    function transferOwner(address newOwner) external onlyOwner{
        owner = newOwner;
    }
}