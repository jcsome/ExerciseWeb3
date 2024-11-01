const { mainnet } = require('viem/chains');
const { createPublicClient, encodeTypedData, http } = require('viem');
const { Wallet } = require('ethers');


// 使用 ethers 生成一个签名钱包
const privateKey = '116dc618ec686da1db305851bb0a20b8c8b6d926ee8422b551379e9e85667eff';
const wallet = new Wallet(privateKey);

// 配置 viem 客户端（用于链 ID 和网络配置）
const client = createPublicClient({
  chain: mainnet,
  transport: http(),
});

// 定义 EIP-712 规则的域分离（Domain Separator）
const domain = {
  name: 'OfflineSignedNFT',
  version: 'OSNFT',
  chainId: 1, // Mainnet
  verifyingContract: '0xYourContractAddressHere',
};

// 定义 EIP-712 的类型结构
const types = {
  TransferRequest: [
    { name: 'from', type: 'address' },
    { name: 'to', type: 'address' },
    { name: 'amount', type: 'uint256' },
  ],
};

// 定义 EIP-712 的数据结构
const message = {
  from: '0xYourAddressHere',
  to: '0xRecipientAddressHere',
  amount: 1000, // Example amount
};

async function signTypedData() {
  // 使用 viem 进行数据编码
  const { domain: encodedDomain, types: encodedTypes, message: encodedMessage } = encodeTypedData({
    domain,
    types,
    primaryType: 'Transfer',
    message,
  });

  // 生成 EIP-712 签名数据
  const dataToSign = {
    domain: encodedDomain,
    types: encodedTypes,
    message: encodedMessage,
  };

  // 使用 ethers 的 Wallet 签名
  const signature = await wallet._signTypedData(dataToSign.domain, d
