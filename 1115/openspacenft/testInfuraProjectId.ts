import {ethers} from 'ethers';

const provider = new ethers.JsonRpcProvider('https://sepolia.infura.io/v3/b9794ad1ddf84dfb8c34d6bb5dca2001');

async function testConnection() {
    const block = await provider.getBlockNumber();
    console.log('Current block number:', block);
}
testConnection();