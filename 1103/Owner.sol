//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyWallet { 
    public string name;
    private mapping (address => bool) approved;
    public address owner;

    modifier auth {
        require (msg.sender == owner, "Not authorized");
        _;
    }

    constructor(string _name) {
        name = _name;
        owner = msg.sender;
    } 

    function setOwner(address _addr) auth {
        assembly {
            sstore(2, _addr)
        }
    }

    function getOwner() public view returns (address _addr) {
        assembly {
            _address := sload(2)
        }
    }

    function transferOwernship(address _addr) auth {
        require(_addr!=address(0), "New owner is the zero address");
        require(owner != _addr, "New owner is the same as the old owner");
        owner = _addr;
    }
}