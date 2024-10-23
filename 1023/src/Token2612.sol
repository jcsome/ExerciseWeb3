// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from"@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {Ownable} from"@openzeppelin/contracts/access/Ownable.sol";

contract Token2612 is ERC20, ERC20Permit, Ownable {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) ERC20Permit(name) Ownable(msg.sender) {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public onlyOwner {
        _burn(from, amount);
    }
}