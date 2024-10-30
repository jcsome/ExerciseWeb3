// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract TestNFT is ERC721 {
    constructor() ERC721("Test NFT", "TNFT") {}

    /**
     * @notice Mints a new NFT to the specified address
     * @param to The address to receive the NFT
     * @param tokenId The ID of the NFT to mint
     */
    function mint(address to, uint256 tokenId) external {
        _mint(to, tokenId);
    }
}