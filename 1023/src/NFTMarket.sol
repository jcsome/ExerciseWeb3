// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {Token2612} from "./Token2612.sol";

contract NFTMarket is IERC721Receiver, EIP712("NFTMarket", "1"){
    bytes32 public constant PERMIT_TYPEHASH =
        keccak256("Permit(address buyer,uint256 tokenId, uint256 price, uint256 nonce)");

    Token2612 public token;  // ERC20 token with permit functionality
    IERC721 public nft;      // NFT contract
    address public signer;   // EIP-712 signer
    // Nonce tracking for permitBuy to prevent replay attacks
    mapping(address => uint256) public nonces; 
    
    /**
     * @dev Permit deadline has expired.
     */
    error ExpiredSignature(uint256 deadline);

    /**
     * @dev Mismatched signature.
     */
    error InvalidSigner(address signer, address owner);

    struct Listing {
        address seller;
        uint256 price;  // Price in ERC20 tokens
    }

    // Mapping of NFT IDs to their listings
    mapping(uint256 => Listing) public listings;

    event Listed(uint256 indexed tokenId, address indexed seller, uint256 price);
    event Purchased(uint256 indexed tokenId, address indexed buyer, address indexed seller, uint256 price);

    /**
     * @notice Constructor to initialize NFT and token contracts
     * @param _nft The address of the NFT contract
     * @param _token The address of the Token2612 contract
     */
    constructor(IERC721 _nft, Token2612 _token, address _signer){
        nft = _nft;
        token = _token;
        signer = _signer;
    }

    /**
     * @notice Function for NFT owners to list their NFTs for sale
     * @param tokenId The ID of the NFT to list
     * @param price The sale price in ERC20 tokens
     */
    function list(uint256 tokenId, uint256 price) external {
        // require(nft.ownerOf(tokenId) == msg.sender, "You are not the owner of this NFT");
        require(price > 0, "Price must be greater than 0");

        // Transfer the NFT to the market contract for custody
        nft.transferFrom(msg.sender, address(this), tokenId);

        // Create the listing
        listings[tokenId] = Listing({
            seller: msg.sender,
            price: price
        });

        emit Listed(tokenId, msg.sender, price);
    }

    /**
     * @notice Function to purchase an NFT using permit for token approval
     * @param tokenId The ID of the NFT to purchase
     * @param nonce The nonce for the permit signature
     * @param v The recovery byte of the signature
     * @param r Half of the ECDSA signature pair
     * @param s Half of the ECDSA signature pair
     */
    function permitBuy(
        address buyer,
        uint256 tokenId,
        uint256 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        Listing memory listing = listings[tokenId];
        // Check if the authorization is valid
        bool success = permit(
            buyer, 
            tokenId,
            listing.price,
            nonce,
            v, r, s);
        require(success, "Invalid signature");

        // Transfer the ERC20 tokens from buyer to seller
        token.transferFrom(buyer, listing.seller, listing.price);

        // Transfer the NFT from marketplace to buyer
        nft.safeTransferFrom(address(this), buyer, tokenId);

        // Clear the listing
        delete listings[tokenId];

        emit Purchased(tokenId, buyer, listing.seller, listing.price);
    }

    /**
     * @dev IERC721Receiver implementation to handle NFT transfer callback
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function permit(
        address buyer, 
        uint256 tokenId, 
        uint256 price, 
        uint256 nonce,
        uint8 v, 
        bytes32 r, 
        bytes32 s
        ) internal view returns (bool){
        // if (block.timestamp > deadline) {
        //     revert ExpiredSignature(deadline);
        // }

        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, buyer, tokenId, price, nonce));

        bytes32 hash = _hashTypedDataV4(structHash);

        address _signer = ECDSA.recover(hash, v, r, s);
        if (_signer != signer) {
            revert InvalidSigner(_signer, signer);
        }
        
        return true;
    }

    function hashWithDomainSeparator(bytes32 structHash) public view returns (bytes32) {
        return _hashTypedDataV4(structHash);
    }
}
