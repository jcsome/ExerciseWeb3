// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "1013/TokenBank.sol";
import "1014/HookERC20/ExtendERC20.sol";

contract TokenBankV2 is TokenBank, ITokenReceiver {
    
    constructor(IERC20 _token) TokenBank(_token) {

    }

    function tokenReceived(address from, uint256 value, bytes data) external{
        require(msg.sender==address(token), "TokenBankV2: token received not ERC20 token");
        balances[from] += value;
    }
}