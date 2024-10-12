// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Bank {
    address public owner;
    mapping (address => uint256) public deposits;
    address[3] public topDepositors;

    constructor () {
        owner = msg.sender; //The address deploying the contract is set as the “Owner” of the contract
    }

    receive() external payable { 
        require(msg.value>0, "Deposit amount must be greater than 0");
        deposits[msg.sender] += msg.value;

        _updateTopDepositors(msg.sender);
    }

    function withdraw(uint256 amount) external onlyOwner{
        require(amount <= address(this).balance, "Not enough balance in contract");
        payable(owner).transfer(amount);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _; //Allow the contract to continue execution even if the modifier is not invoked
    }
    
    function _updateTopDepositors (address user) internal {
        for (uint256 i = 0; i < 3; i++) {
            if (topDepositors[i] == user) {
                _rearrangeTopDepositors();
                return;
            }
        }

        if (deposits[user] > deposits[topDepositors[2]]) {
            topDepositors[2] = user;
            _rearrangeTopDepositors();
        }
    }

    function _rearrangeTopDepositors() internal {
        for (uint256 i=1; i<3; i++) {
            for (uint256 j=i; j>0 && deposits[topDepositors[j]]>deposits[topDepositors[j-1]]; j--) {
                address temp = topDepositors[j]; 
                topDepositors[j] = topDepositors[j-1];
                topDepositors[j-1] = temp;
            }
        }
    }

    function getTopDepositors() external view returns (address[3] memory) {
        address[3] memory topDepositorsMemory;
        for (uint i = 0; i < 3; i++) {
            topDepositorsMemory[i] = topDepositors[i];
        }
        return topDepositorsMemory;
    }


    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}