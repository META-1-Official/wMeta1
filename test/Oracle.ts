// We import Chai to use its asserting functions here.
import { Contract, ContractFactory } from "ethers";
import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

const { expect } = require("chai");

let _oracleContract: ContractFactory;
let oracleContract: Contract;
let owner: SignerWithAddress;

describe("AggregatorOracle", function () {
  beforeEach(async function () {
    _oracleContract = await ethers.getContractFactory("AggregatorOracle");
    [owner] = await ethers.getSigners();

    oracleContract = await _oracleContract.deploy(
      "0x9331b55D9830EF609A2aBCfAc0FBCE050A52fdEa"
    );
  });

  // You can nest describe calls to create subsections.
  describe("Deployment", function () {
    it("Should give the price from the chain link contract", async function () {
      try {
        console.log(
          await oracleContract.attach(owner.address).getLatestPrice()
        );
      } catch (e) {
        console.log(e);
      }
      expect(await oracleContract.signer.getAddress()).to.equal(owner.address);
    });
  });
});
