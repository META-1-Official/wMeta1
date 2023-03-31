# wMETA1 Project

This project contains smart contracts and scripts to deploy and interact with wMETA over any EVM compatible chain (ETH, BSC, POLYGON etc) also it has a withdrawal contract which can be used to trade wMETA using USDT

## Deploy wMETA

### Setup
* Clone this repo
* run `npm i` to install dependencies
* rename `.env.example` to `.env` and setup environment variables accordingly

### Compile
* Run `npx hardhat compile` in the project root to compile all smart contracts

### Deploy
* Run `npx hardhat run scripts/WrappedMetaDeploy.ts --network <BSCTestnet|BSCMainnet>` to deploy the wMeta smart contract on the selected network  
for example, run `npx hardhat run scripts/WrappedMetaDeploy.ts --network BSCMainnet` to deploy wMeta on Binance Smart Chain Mainnet.  
*Make sure the private key you set in .env has at-least 0.1 BNB to deploy the contracts*  
*Once you deploy the wMeta contract, the private key you set in `.env` will receive all 100M wMeta tokens*


## Deploy Withdrawal Contract
* Run `npx hardhat run scripts/WithdrawContractDeploy.ts --network <BSCTestnet|BSCMainnet>` to deploy the Withdrawal smart contract on the selected network  
  for example, run `npx hardhat run scripts/WithdrawContractDeploy.ts --network BSCMainnet` to deploy Withdrawal smart contract on Binance Smart Chain Mainnet.  
  *Make sure the private key you set in .env has at-least 0.1 BNB to deploy the contracts*


*Withdrawal contract is upgradable*  
*any wallet with role `PRICE_UPDATE_ROLE` can update rates in WIthdrawal contract which will be used to deposit or withdraw wMeta against USDT*  
*Price precision is 8*  

## Test

Run `npx hardhat test` to test all smart contracts on local hardhat chain
