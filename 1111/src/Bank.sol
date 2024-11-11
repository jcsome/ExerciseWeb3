// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AutomationCompatibleInterface} from "./AutomationCompatibleInterface.sol";

contract Bank is AutomationCompatibleInterface{ 

    address public owner;
    mapping(address => uint) public balance;

    event Deposit(address indexed from, uint value);

    constructor() {
        owner = msg.sender;
    }

    function deposit() public payable {
        balance[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint amount) public {
        require(balance[msg.sender] >= amount, "Insufficient balance");
        balance[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }

    function transfer(address to, uint amount) public {
        require(balance[msg.sender] >= amount, "Insufficient balance");
        balance[msg.sender] -= amount;
        balance[to] += amount;
    }

    function withdrawAll() public {
        require(owner == msg.sender, "Only owner can withdraw all funds");
        payable(msg.sender).transfer(address(this).balance);
    }

    function checkUpkeep(bytes calldata checkData) external returns (bool upkeepNeeded, bytes memory performData) {
        upkeepNeeded = address(this).balance > 1 ether;
        return (upkeepNeeded, performData);
    }

    function performUpkeep(bytes calldata performData) external {
        if (address(this).balance > 1 ether) {
            payable(owner).transfer(address(this).balance/2);
        }
    }
}