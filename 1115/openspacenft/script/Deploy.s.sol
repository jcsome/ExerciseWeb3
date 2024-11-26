// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../src/FlattenedOpenspaceNFT.sol";
import "@openzeppelin/contracts/utils/Create2.sol";

contract DeployScipt is Script {
    // 使用 Create2 部署合约（带盐值）
    bytes32 constant SALT = 0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef;

    function run() public {
        uint256 deployerPrvatekey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrvatekey);

        OpenspaceNFT openspaceNft = new OpenspaceNFT{salt: SALT}();
        console2.log("OpenspaceNFT deployed at: ", address(openspaceNft));
        console2.log("OpenspaceNFT owner: ", openspaceNft.owner());

        vm.stopBroadcast();
    }
}