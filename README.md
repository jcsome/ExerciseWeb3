# ExerciseWeb3

cast wallet command: 

```
// cast wallet new -> private key -> .env
$ forge create --private-key --rpc-url http://127.0.0.1:8545 --rpc-url https://ethereum-sepolia-rpc.publicnode.com
$ forge script -sig "deploy()" --boradcast

/**
.env 明文私钥不安全
  1. 加密 keystore
  2. 硬件钱包 hardware wallet
  3. 连接到AWS的 KSM
*/

$ forge create —-account s4tester
$ forge script --account

$ forge verify-contract \
	--chain sepolia \
	--constructor-args "$(cast abi-encode 'constructor(string memory name_, string memory symbol_ )' MyFirstToken MFT)" \
	0x042ed9666b1545F241C03010419c400C9Db0407 MyFirstToken \
```