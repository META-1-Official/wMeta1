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

  const _withdrawContract = await WithdrawContract.attach(String(process.env.WITHDRAW_CONTRACT));

  await _withdrawContract.transferOwnership(process.env.GNOSIS_SAFE_ADDRESS);

  console.log("All done!!!");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
