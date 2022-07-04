// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";
import { BigNumber } from "ethers";

async function main() {
  const WITHDRAW_CONTRACT_ADDRESS =
    "0xacF96Ad1959050f0Fb0Bb6fbc22cA4bab814D92C";
  const USDT_CONTRACT_ADDRESS = "0x337610d27c682E347C9cD60BD4b3b107C9d34dDd";
  const wMETA1_CONTRACT_ADDRESS = "0xf6E84Ea2b0BB2612b753Fbce5B145a32454307f4";
  // We get the contract to deploy
  const WithdrawContract = (
    await ethers.getContractFactory("WithdrawContract")
  ).attach(WITHDRAW_CONTRACT_ADDRESS);

  const USDTContract = (await ethers.getContractFactory("WrappedMeta")).attach(
    USDT_CONTRACT_ADDRESS
  );

  const wMETA1Contract = (
    await ethers.getContractFactory("WrappedMeta")
  ).attach(wMETA1_CONTRACT_ADDRESS);
  //
  // console.log(
  //   await WithdrawContract.calcDepositAmount(
  //     BigNumber.from("10000000000000000000")
  //   )
  // );

  // await wMETA1Contract.transfer(
  //   WITHDRAW_CONTRACT_ADDRESS,
  //   BigNumber.from("10000000000000000000")
  // );

  // // Approve USDT
  // await USDTContract.approve(
  //   WITHDRAW_CONTRACT_ADDRESS,
  //   BigNumber.from("1000000000000000000000")
  // );

  // Perform deposit
  // await WithdrawContract.deposit(BigNumber.from("10000000000000000000"));

  // await wMETA1Contract.approve(
  //   WITHDRAW_CONTRACT_ADDRESS,
  //   BigNumber.from("1000000000000000000000")
  // );
  // Perform deposit
  await WithdrawContract.withdraw(BigNumber.from("26660650000000000"));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
