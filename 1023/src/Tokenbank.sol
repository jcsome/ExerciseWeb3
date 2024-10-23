// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Token2612} from "./Token2612.sol";

/**
 * @title TokenBank
 * @notice A simple token bank that allows deposit, withdrawal, and permit-based deposits using Token2612(based on ERC20permit) tokens.
 */
contract TokenBank {

    Token2612 public token;
    mapping (address => uint256) public balances;

    /**
     * @notice Constructor to set the Token2612 token contract
     * @param _token The address of the Token2612 token contract
     */
    constructor (Token2612 _token) {
        token = _token;
    }

    /**
     * @notice Deposits a specified amount of tokens into the bank
     * @dev Caller must have approved the bank contract to transfer the specified amount
     * @param amount The amount of tokens to deposit
     */
    function deposit(uint256 amount) public {
        require(amount > 0, "Amount must be greater than zero");
        bool success = token.transferFrom(msg.sender, address(this), amount);
        require(success, "Token transfer failed");
        balances[msg.sender] += amount;
    }

    /**
     * @notice Withdraws a specified amount of tokens from the bank
     * @param value The amount of tokens to withdraw
     */
    function withdraw(uint256 value) public {
        require(value <= balances[msg.sender], "Insufficient balance");
        bool success = token.transfer(msg.sender, value);
        require(success, "Token transfer failed");
        balances[msg.sender] -= value;
    }

    /**
     * @notice Deposits tokens on behalf of an owner using EIP-2612 permit
     * @dev Allows a spender to deposit tokens from an owner's account with their permission
     * @param owner The address of the token owner
     * @param spender The address permitted to spend the tokens
     * @param value The amount of tokens to deposit
     * @param deadline The timestamp until when the signature is valid
     * @param v The recovery byte of the signature
     * @param r Half of the ECDSA signature pair
     * @param s Half of the ECDSA signature pair
     */
    function permitDeposit(
        address owner, 
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        require(value > 0, "Amount must be greater than zero");
        token.permit(owner, spender, value, deadline, v, r, s);
        bool success = token.transferFrom(owner, spender, value);
        require(success, "Token transfer failed");
        balances[spender] += value;
        balances[owner] -= value;
    }
}
