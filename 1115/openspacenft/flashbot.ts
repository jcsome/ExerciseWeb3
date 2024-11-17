// First, install the required packages by running:
// npm install ethers @flashbots/ethers-provider-bundle

import { ethers } from 'ethers';
import { FlashbotsBundleProvider, FlashbotsBundleResolution } from '@flashbots/ethers-provider-bundle';
import * as dotenv from 'dotenv';
import { hash } from 'crypto';

async function main() {

    // Load environment variables from .env file
    dotenv.config();

    if (!process.env.PRIVATE_KEY) {
        throw new Error("PRIVATE_KEY is not defined in the environment variables");
    }
    const ownerPrivateKey = process.env.PRIVATE_KEY;
    const userPrivateKey = process.env.PRIVATE_KEY;

    // Set up the Sepolia network provider
    const provider = new ethers.JsonRpcProvider('https://sepolia.infura.io/v3/b9794ad1ddf84dfb8c34d6bb5dca2001');

    const ownerWallet = new ethers.Wallet(ownerPrivateKey, provider);
    const userWallet = new ethers.Wallet(userPrivateKey, provider);

    // Set up the Flashbots provider
    const FLASHBOTS_ENDPOINT = 'https://relay-sepolia.flashbots.net';
    const authSigner = ethers.Wallet.createRandom();

    const flashbotsProvider = await FlashbotsBundleProvider.create(provider, authSigner, FLASHBOTS_ENDPOINT);

    // Replace with your deployed contract address
    const contractAddress = '0xA0f2A629Def24b412CB01636cc83c981B6Fc1ceE';

    const abi = [
        "function enablePresale() external",
        "function presale(uint256 amount) external payable"
    ];

    const contractOwner = new ethers.Contract(contractAddress, abi, ownerWallet);
    const contractUser = new ethers.Contract(contractAddress, abi, userWallet);

    const enablePresaleData = contractOwner.interface.encodeFunctionData('enablePresale');
    const presaleData = contractUser.interface.encodeFunctionData('presale', [1]); // Purchasing 1 NFT

    const ownerNonce = await provider.getTransactionCount(ownerWallet.address);
    const userNonce = await provider.getTransactionCount(userWallet.address);

    const blockNumber = await provider.getBlockNumber();
    const latestBlock = await provider.getBlock("latest");
    const baseGasPrice = latestBlock?.baseFeePerGas;
    if (!baseGasPrice) {
        throw new Error("Base gas price is not available");
    }
    var targetBlockNumber = blockNumber + 1; // Targeting two blocks ahead
    const gasPrice = baseGasPrice * BigInt(20); // Base gas price + 1 Gwei

    // Prepare the transactions
    const tx1 = {
        signer: ownerWallet,
        transaction: {
            chainId: 11155111, // Sepolia chain ID
            to: contractAddress,
            data: enablePresaleData,
            gasPrice: gasPrice, // Base gas price + 1 Gwei
            gasLimit: 2000000000,
            nonce: ownerNonce,
            value: 0,
        },
    };

    const tx2 = {
        signer: userWallet,
        transaction: {
            chainId: 11155111,
            to: contractAddress,
            data: presaleData,
            gasPrice: gasPrice,
            gasLimit: 2000000000,
            nonce: userNonce,
            value: ethers.parseEther('0.01'), // Cost for 1 NFT
        },
    };

    // Bundle the transactions
    const bundle = [tx1];

    for (let i = 0; i < 10; i++) {
        targetBlockNumber = blockNumber + i;
        // Send the bundle
        const bundleResponse = await flashbotsProvider.sendBundle(bundle, targetBlockNumber);

        if ('error' in bundleResponse) {
            console.error('Bundle submission error:', bundleResponse.error.message);
            return;
        }

        console.log('Bundle submitted, waiting for inclusion...: ');

        // Wait for the bundle to be included
        const resolution = await bundleResponse.wait();
        console.log('Bundle resolution:', resolution);

        if (resolution === FlashbotsBundleResolution.BundleIncluded) {
            console.log('Bundle included in block:', targetBlockNumber);
            const txHashes = bundleResponse.bundleTransactions.map(tx => tx.hash);
            console.log('Transaction Hashes:', txHashes);

            // Get bundle stats
            const bundleStats = await flashbotsProvider.getBundleStats(bundleResponse.bundleHash, targetBlockNumber);
            console.log('Bundle Stats:', bundleStats);
            return;

        } else if (resolution === FlashbotsBundleResolution.BlockPassedWithoutInclusion) {
            console.log('Bundle not included in block:', targetBlockNumber);
        } else {
            console.log('Unexpected bundle resolution:', resolution);
        }
    }
}

main().catch((error) => {
    console.error('Error executing script:', error);
});