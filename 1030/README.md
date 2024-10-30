https://thegraph.com/studio/subgraph/wathcher-nftmarket/endpoints 
1280  cd ../..
 1281  cd 1023
 1282  cast send 0x776884b7eB9CD154B6f585eCd58870F45A8f6Aeb "mint(address to, uint256 amount)" 0xF195e14685a7c7B1C9d4Df10664EA0A2dAab4e8C 10000 --rpc-url sepolia --account fox
 1283  cast send 0x170A25Cd9E96135aDDACbCa0CAee05Eb219D9c8D "mint(address to, uint256 tokenId)" 0xc72F5abe9265070F5523D5670C60CEb88bB010e7 521 --rpc-url sepolia --account fox
 1284  cast send 0x9F0646722d4443bffB377C00F8960fc2442A4534 "list(uint256 tokenId, uint256 price)" 521 5000 --rpc-url sepolia --account fox
 1285  cast send 0x170A25Cd9E96135aDDACbCa0CAee05Eb219D9c8D "approve(address to, uint256 tokenId)" 0x9F0646722d4443bffB377C00F8960fc2442A4534 521 --rpc-url sepolia --account fox
 1286  cast send 0x776884b7eB9CD154B6f585eCd58870F45A8f6Aeb "approve(address spender, uint256 value)" 0x9F0646722d4443bffB377C00F8960fc2442A4534 10000 --rpc-url sepolia --account fox
 1287  cast send 0x776884b7eB9CD154B6f585eCd58870F45A8f6Aeb "balanceOf(address account)" 0xc72F5abe9265070F5523D5670C60CEb88bB010e7  --rpc-url sepolia --account fox
 1288  git status
 1289  cd ..
 1290  cd 1030
 1291  git sttus
 1292  git status
 1293  git add .
 1294  git commit 
 1295  git status
