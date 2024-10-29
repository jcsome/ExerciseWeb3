// main.js
import { createPublicClient, webSocket, formatUnits } from 'viem';
import { mainnet } from 'viem/chains';
import { UsdtAbi } from './UsdtAbi.json';

const blockDiv = document.getElementById('blocks');
const transfersDiv = document.getElementById('transfers');

// Replace 'YOUR_INFURA_PROJECT_ID' with your actual Infura Project ID
const client = createPublicClient({
  chain: mainnet,
  transport: webSocket('wss://mainnet.gateway.tenderly.co'),
});

// 1. Listen to new blocks and display block height and hash
client.watchBlocks({
  onBlock: (block) => {
    const blockNumber = block.number;
    const blockHash = block.hash;
    const blockInfo = `Block Number: ${blockNumber}, Block Hash: ${blockHash}`;
    console.log(blockInfo);
    const p = document.createElement('p');
    p.textContent = blockInfo;
    blockDiv.appendChild(p);
  },
  onError: (error) => console.error('Block Error:', error),
});

// USDT Contract Address
const usdtAddress = '0xdAC17F958D2ee523a2206206994597C13D831ec7';

// ABI for the Transfer event
const transferEventAbi = [
  {
    type: 'event',
    name: 'Transfer',
    inputs: [
      { name: 'from', type: 'address', indexed: true },
      { name: 'to', type: 'address', indexed: true },
      { name: 'value', type: 'uint256', indexed: false },
    ],
  },
];

// 2. Real-time collection and display of USDT Transfer events
client.watchContractEvent({
  address: usdtAddress,
  abi: transferEventAbi,
  eventName: 'Transfer',
  onLogs: (logs) => {
    logs.forEach((log) => {
      console.log('Received log:', log);
      const args = log.args;
  
      if (!args) {
        console.log('No args found in log:', log);
        return;
      }
      
      const from = args.from;
      const to = args.to;
      const value = args.value;

      // Create transfer container
      const transferContainer = document.createElement('div');
      transferContainer.style.border = '1px solid #ccc';
      transferContainer.style.padding = '10px';
      transferContainer.style.margin = '10px 0';
  
      // Create a paragraph to display 'from'
      const fromP = document.createElement('p');
      fromP.textContent = `From: ${from}`;
      transferContainer.appendChild(fromP);
  
      // Create a paragraph to display 'to'
      const toP = document.createElement('p');
      toP.textContent = `To: ${to}`;
      transferContainer.appendChild(toP);
  
      // Create a paragraph to display 'value'
      const valueP = document.createElement('p');
      valueP.textContent = `Value: ${formatUnits(value, 6)} USDT`;
      transferContainer.appendChild(valueP);
  
      // Append transfer container to transfersDiv
      transfersDiv.appendChild(transferContainer);
  
      // Log the transfer details
      console.log(`From: ${from}`);
      console.log(`To: ${to}`);
      console.log(`Value: ${formatUnits(value, 6)} USDT`);
    });
  },
  
  onError: (error) => console.error('Event Error:', error),
});
