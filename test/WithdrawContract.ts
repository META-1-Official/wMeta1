// We import Chai to use its asserting functions here.
import { BigNumber, Contract } from "ethers";
import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

const { expect } = require("chai");

describe("Withdraw Contract", function () {
  let WithdrawContract;
  let withdrawContract: Contract;
  let owner: SignerWithAddress;
  let addr1: SignerWithAddress;
  let addr2: SignerWithAddress;

  beforeEach(async function () {
    WithdrawContract = await ethers.getContractFactory("WithdrawContract");
    [owner, addr1, addr2] = await ethers.getSigners();
    withdrawContract = await WithdrawContract.deploy();
    await withdrawContract.deployed();
    console.log(withdrawContract.address);
  });

  describe("Deployment", function () {
    it("Should set the right owner", async function () {

    });
  });
});
