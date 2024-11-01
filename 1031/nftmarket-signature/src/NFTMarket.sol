// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {OfflineSignedNFT} from "./OfflineSignedNFT.sol";

contract NFTMarket is Ownable {

    struct Listing {
        address seller; // Address of the seller
        address nftContract; // NFT contract address
        uint256 tokenId; // NFT token ID
        uint256 price; // Price in ETH
        uint256 listingEndTime; // Listing expiration time
        bytes signature; // Signature of the seller
        uint256 nonce; // Nonce for replay attack prevention
    }

    // List of NFT listings
    Listing[] public nftListings;

    // Mapping to track nonces to prevent replay attacks
    mapping(bytes => bool) public usedSignatures;

    // Events
    event NFTListed(address indexed seller, address indexed nftContract, uint256 indexed tokenId, uint256 price, uint256 listingEndTime);
    event NFTPurchased(address indexed buyer, address indexed seller, address indexed nftContract, uint256 tokenId, uint256 price);

    constructor() Ownable(msg.sender) {}

    /**
     * @dev Lists an NFT on the marketplace.
     * @param listing The listing details.
     */
    function listNFT(Listing memory listing) external {
        require(listing.listingEndTime > block.timestamp, "Listing has expired");
        require(!usedSignatures[listing.signature], "Signature already used");

        // Verify signature
        bool validSignature = OfflineSignedNFT(
                listing.nftContract
            ).approveWithSignature(
                listing.seller, 
                address(this), 
                listing.tokenId,
                listing.nonce,
                listing.signature
            );
        require(validSignature, "Invalid signature");

        // Mark the signature as used
        usedSignatures[listing.signature] = true;

        // Transfer NFT from seller to the contract to hold it for sale
        ERC721(listing.nftContract).transferFrom(listing.seller, address(this), listing.tokenId);

        // Add the listing to the listings array
        nftListings.push(listing);

        emit NFTListed(listing.seller, listing.nftContract, listing.tokenId, listing.price, listing.listingEndTime);
    }

    /**
     * @dev Returns the latest active NFT listings.
     * @return Listing[] Array of active NFT listings.
     */
    function getLatestNFTListings() external view returns (Listing[] memory) {
        uint256 activeCount;
        for (uint256 i = 0; i < nftListings.length; i++) {
            if (nftListings[i].listingEndTime > block.timestamp) {
                activeCount++;
            }
        }

        Listing[] memory activeListings = new Listing[](activeCount);
        uint256 index = 0;
        for (uint256 i = 0; i < nftListings.length; i++) {
            if (nftListings[i].listingEndTime > block.timestamp) {
                activeListings[index] = nftListings[i];
                index++;
            }
        }

        return activeListings;
    }

    /**
     * @dev Purchases an NFT by paying ETH.
     * @param index The index of the listing in the nftListings array.
     */
    function buyNFT(uint256 index) external payable {
        Listing memory listing = nftListings[index];
        require(listing.listingEndTime > block.timestamp, "Listing has expired");
        require(msg.value >= listing.price, "Insufficient ETH to buy NFT");

        // Transfer the NFT to the buyer
        ERC721(listing.nftContract).transferFrom(address(this), msg.sender, listing.tokenId);

        // Transfer the payment to the seller
        payable(listing.seller).transfer(listing.price);

        // Emit event for purchase
        emit NFTPurchased(msg.sender, listing.seller, listing.nftContract, listing.tokenId, listing.price);

        // Remove the listing
        _removeListing(index);
    }

    /**
     * @dev Removes a listing from the nftListings array.
     * @param index The index of the listing to be removed.
     */
    function _removeListing(uint256 index) internal {
        require(index < nftListings.length, "Invalid index");

        nftListings[index] = nftListings[nftListings.length - 1];
        nftListings.pop();
    }
}
