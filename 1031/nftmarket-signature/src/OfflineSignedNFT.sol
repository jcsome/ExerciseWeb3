// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title OfflineSignedNFT
 * @dev An ERC721 NFT contract with support for offline-signed transfer transactions.
 * Allows users to sign transfer requests offline, which can be verified and executed on-chain.
 */
contract OfflineSignedNFT is ERC721, EIP712, Ownable {
    using ECDSA for bytes32;

    // Domain and version for EIP-712 structured data signing.
    string private constant _SIGNING_DOMAIN = "OfflineSignedNFT";
    string private constant _SIGNATURE_VERSION = "1";

    /**
     * @dev Structure for transfer request data to be signed offline.
     * @param from The address of the current owner of the token.
     * @param to The address to transfer the token to.
     * @param tokenId The ID of the token to be transferred.
     * @param nonce A unique number to prevent replay attacks.
     */
    struct TransferRequest {
        address from;
        address to;
        uint256 tokenId;
        uint256 nonce;
    }

    // Mapping to track used nonces for preventing replay attacks.
    mapping(uint256 => bool) public usedNonces;

    /**
     * @dev Contract constructor. Initializes the ERC721 token and EIP712 domain.
     */
    constructor() ERC721("OfflineSignedNFT", "OSNFT") EIP712(_SIGNING_DOMAIN, _SIGNATURE_VERSION) Ownable(msg.sender){}

    /**
     * @dev Mint a new token.
     * @param to The address that will own the minted token.
     * @param tokenId The ID of the token to mint.
     */
    function mint(address to, uint256 tokenId) external onlyOwner {
        _mint(to, tokenId);
    }

    /**
     * @dev Verifies the signature for a given transfer request.
     * @param from The address of the token owner.
     * @param to The address to transfer the token to.
     * @param tokenId The ID of the token to be transferred.
     * @param nonce A unique number to prevent replay attacks.
     * @param signature The signed data generated offline by the token owner.
     * @return bool Returns true if the signature is valid, otherwise false.
     */
    function verifySignature(
        address from,
        address to,
        uint256 tokenId,
        uint256 nonce,
        bytes memory signature
    ) public view returns (bool) {
        TransferRequest memory request = TransferRequest({
            from: from,
            to: to,
            tokenId: tokenId,
            nonce: nonce
        });

        // Create the hash of the transfer request following EIP-712 encoding.
        bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
            keccak256("TransferRequest(address from,address to,uint256 tokenId,uint256 nonce)"),
            request.from,
            request.to,
            request.tokenId,
            request.nonce
        )));
        
        // Recover the signer address from the digest and signature.
        address signer = ECDSA.recover(digest, signature);
        return signer == from;
    }

    /**
     * @dev Executes a token transfer based on a valid offline signature.
     * @param from The address of the token owner.
     * @param to The address to transfer the token to.
     * @param tokenId The ID of the token to be transferred.
     * @param nonce A unique number to prevent replay attacks.
     * @param signature The signed data generated offline by the token owner.
     * Requirements:
     * - The signature must be valid and signed by the token owner.
     * - The nonce must not have been used before.
     * - The caller must be the token owner or approved.
     */
    function transferWithSignature(
        address from,
        address to,
        uint256 tokenId,
        uint256 nonce,
        bytes memory signature
    ) external {
        require(_isApprovedOrOwner(from, tokenId), "Not owner nor approved");
        require(!usedNonces[nonce], "Nonce already used");
        require(verifySignature(from, to, tokenId, nonce, signature), "Invalid signature");

        // Mark the nonce as used to prevent replay attacks.
        usedNonces[nonce] = true;

        // Execute the transfer.
        _transfer(from, to, tokenId);
    }

    function approveWithSignature(
        address owner,
        address spender,
        uint256 tokenId,
        uint256 nonce,
        bytes memory signature
    ) external returns (bool){
        require(_isApprovedOrOwner(owner, tokenId), "Not owner nor approved");
        require(!usedNonces[nonce], "Nonce already used");
        require(verifySignature(owner, spender, tokenId, nonce, signature), "Invalid signature");

        // Mark the nonce as used to prevent replay attacks.
        usedNonces[nonce] = true;

        // Execute the approval.
        approve(spender, tokenId);
        return true;
    }

    
    /**
     * @dev Checks if the spender is approved or the owner of the token.
     * @param spender The address to check.
     * @param tokenId The ID of the token.
     * @return bool Returns true if the spender is approved or the owner of the token.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }
}
