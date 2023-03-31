// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers} from "hardhat";
require('dotenv').config();

async function main() {

  // We get the contract to deploy
  const WithdrawContract = await ethers.getContractFactory("WithdrawContract");
  const withdrawContract = await WithdrawContract.deploy(String(process.env.WMETA_ADDRESS), String(process.env.USDT_ADDRESS));
  await withdrawContract.deployed();
  console.log("WithdrawContract deployed to:", withdrawContract.address);

  console.log("Granting Price Update Role to ", process.env.PRICE_USER_ROLE_ADDRESS);

  const _withdrawContract = await WithdrawContract.attach(withdrawContract.address);

  await _withdrawContract.givePriceUpdateRole(String(process.env.PRICE_USER_ROLE_ADDRESS));

  console.log("All done!!!");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
