// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {NFTMarket} from "../src/NFTMarket.sol";
import {Token2612} from "../src/Token2612.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NFTMarketTest is Test {
    bytes32 public constant DOMAIN_TYPEHASH =  keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    
    NFTMarket public nftMarket;
    Token2612 public token;
    TestNFT public nft;

    address public seller = address(2);
    address public buyer = address(3);

    // Define the private key for the whitelist signer
    uint256 whitelistPrivateKey = 0xABEF76;

    // Generate the whitelist signer address from the private key using Foundry's vm.addr cheatcode
    address public signer = vm.addr(whitelistPrivateKey);

    function setUp() public {
        // Deploy Token2612 and mint tokens to the buyer
        token = new Token2612("Test Token", "TTK");
        token.mint(buyer, 1000 * 10 ** token.decimals());

        // Deploy TestNFT and mint an NFT to the seller
        nft = new TestNFT();
        nft.mint(seller, 1);

        // Deploy NFTMarket contract
        nftMarket = new NFTMarket(IERC721(nft), token, signer);

        vm.startPrank(buyer);
        token.approve(address(nftMarket), 1000 * 10 ** token.decimals());
        vm.stopPrank();

        // Seller approves NFTMarket to transfer their NFT
        vm.startPrank(seller);
        nft.approve(address(nftMarket), 1);
        vm.stopPrank();
    }

    /**
     * @notice Test token deposit functionality
     */
    function testTokenDeposit() public {
        // Buyer deposits tokens into the NFTMarket contract
        vm.startPrank(buyer);
        token.approve(address(nftMarket), 100 * 10 ** token.decimals());
        token.transfer(address(nftMarket), 100 * 10 ** token.decimals());
        vm.stopPrank();

        // Verify the NFTMarket contract received the tokens
        assertEq(token.balanceOf(address(nftMarket)), 100 * 10 ** token.decimals());
    }

    /**
     * @notice Test successful NFT purchase using permitBuy
     */
    function testNFTPurchase() public {
        // Seller lists the NFT for sale
        vm.startPrank(seller);
        nftMarket.list(1, 100 * 10 ** token.decimals());
        vm.stopPrank();

        // Prepare parameters for permitBuy
        uint256 tokenId = 1;
        uint256 amount = 100 * 10 ** token.decimals();
        uint256 nonce = nftMarket.nonces(buyer);

        // Generate the signature for whitelist authorization from the signer
        bytes32 structHash = keccak256(
            abi.encode(
                nftMarket.PERMIT_TYPEHASH(),
                buyer,
                tokenId,
                amount,
                nonce
            )
        );

        // Create the EIP-712 domain separator
        bytes32 DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes("NFTMarket")),
                keccak256(bytes("1")),
                block.chainid,
                address(nftMarket)
            )
        );


        // Compute the final digest to be signed
        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash)
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(whitelistPrivateKey, digest);

        // Buyer calls permitBuy with the signatures
        vm.startPrank(buyer);
        nftMarket.permitBuy(
            buyer,
            tokenId,
            nonce,
            v,
            r,
            s
        );
        vm.stopPrank();

        // Verify the buyer now owns the NFT
        assertEq(nft.ownerOf(1), buyer);

        // Verify the seller received the payment
        assertEq(token.balanceOf(seller), amount);

        // Verify the buyer's token balance decreased
        assertEq(token.balanceOf(buyer), (1000 - 100) * 10 ** token.decimals());
    }
}

/**
 * @title TestNFT
 * @notice Simple ERC721 token for testing purposes
 */
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
