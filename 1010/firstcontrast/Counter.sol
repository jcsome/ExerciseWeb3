// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Counter {

    uint public counter;

    constructor() {
        counter = 0;
    }

    function add() public {
        counter++;
    }
}

// transaction hash: 0xfa59c5a490ff39884b4e1d79293940588d6f1ffd391fdc4c43af9f562d1fd0fa