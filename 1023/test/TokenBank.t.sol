//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {TokenBank} from "../src/TokenBank.sol";
import {Token2612} from "../src/Token2612.sol";

contract TokenBankTest is Test {
    TokenBank public tokenBank;
    Token2612 public token;

    address public owner = address(1);
    address public user = address(2);

    function setUp() public {
        token = new Token2612("Test Token", "TTK");
        token.mint(owner, 1000 * 10 ** token.decimals());

        tokenBank = new TokenBank(token);
    }

    function testDeposit() public {
        token.approve(address(tokenBank), 100 * 10 ** token.decimals());
        tokenBank.deposit(100 * 10 ** token.decimals());

        assertEq(token.balanceOf(address(tokenBank)), 100 * 10 ** token.decimals());
    }

    function testWithdraw() public {
        token.approve(address(tokenBank), 100 * 10 ** token.decimals());
        tokenBank.deposit(100 * 10 ** token.decimals());

        tokenBank.withdraw(50 * 10 ** token.decimals());

        assertEq(token.balanceOf(address(tokenBank)), 50 * 10 ** token.decimals());
    }
}