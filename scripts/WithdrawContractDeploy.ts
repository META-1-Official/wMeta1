// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers, upgrades } from "hardhat";

async function main() {
  /* const Meta1Oracle = await ethers.getContractFactory("Meta1Oracle");
  const _meta1Oracle = await Meta1Oracle.deploy(
    "0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06",
    "0x6caa43759791B00a10774A0aEb62F1Ad2adf1B46"
  );
  await _meta1Oracle.deployed();
  console.log("Meta1Oracle deployed to:", _meta1Oracle.address); */

  // We get the contract to deploy
  const WithdrawContract = await ethers.getContractFactory("WithdrawContract");
  const withdrawContract = await upgrades.deployProxy(WithdrawContract, [
    "0x93Fb7B350D9a8E7ade638FB5b00A7C5E0a7c1F39",
    "0x64b7b34724d21739493b4273535fed4AE5cFF6Af",
  ]);
  await withdrawContract.deployed();
  console.log("WithdrawContract deployed to:", withdrawContract.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
