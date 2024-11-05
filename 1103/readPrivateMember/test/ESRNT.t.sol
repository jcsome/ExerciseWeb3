// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/ESRNT.sol";

contract TestReadLocks is Test{
    esRNT public _esRNT;
    uint256 public _slot;
    
    function setUp() public {
        vm.warp(1690000000);
        _esRNT = new esRNT();
        _slot = 0;
        console.log("block timestamp: %s", block.timestamp);
    }

    function testReadLockInfo() public view {

        uint256 baseSlot = uint256(keccak256(abi.encode(_slot)));
        uint256 locklength = uint256(vm.load(address(_esRNT), bytes32(_slot)));
        for (uint256 i = 0; i < locklength; i++) {
            uint256 userAndTimeSlot = baseSlot + i * 2;
            uint256 amountSlot = baseSlot + i * 2 + 1;
            
            uint256 datauserAndTime = uint256(vm.load(address(_esRNT), bytes32(userAndTimeSlot)));
            uint256 dataAmount = uint256(vm.load(address(_esRNT), bytes32(amountSlot)));
            
            address user = address(uint160(datauserAndTime));
            uint64 startTime = uint64(datauserAndTime >> 160);
            uint256 amount = dataAmount;

            console.log("user: %s, startTime: %s, amount: %s", user, startTime, amount);
        }
    }
}
