// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";
import { BigNumber } from "ethers";

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const WrappedMeta = await ethers.getContractFactory("WrappedMeta");
  const wrappedMeta = await WrappedMeta.attach(
    "0x1aBa557453CfED52ba6B71b48eB9A70D3b74Bc3A"
  );

  const mintAmount = BigNumber.from("1000000000000000000000000");

  await wrappedMeta.mint(
    "0x7296c49a88cb56a859ba4a53aa655be906a46994",
    mintAmount
  );

  console.log(`WrappedMeta minted`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
