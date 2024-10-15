// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "1013/BaseERC20.sol";

interface ITokenReceiver {
    function tokenReceived(address from, uint256 value, uint256 tokenId) external;
}

interface IERC20WithCallback {
    function transferWithCallback(address _to, uint256 _value, uint256 tokenId) external returns (bool);
}

contract ERC20WithCallback is BaseERC20, IERC20WithCallback{
    
    using Address for address;
    function transferWithCallback(address _to, uint256 _value, uint256 tokenId) external returns (bool) {
        transfer(_to, _value);
        if(isContract(_to)) {
            ITokenReceiver(_to).tokenReceived(msg.sender, _value, tokenId);
        }
        return true;
    }

    function isContract(address account) public view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}