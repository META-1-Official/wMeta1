// We import Chai to use its asserting functions here.
import { BigNumber, Contract } from "ethers";
import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

const { expect } = require("chai");

describe("Wrapped Meta Token", function () {
  let MetaToken;
  let wMetaToken: Contract;
  let owner: SignerWithAddress;
  let addr1: SignerWithAddress;
  let addr2: SignerWithAddress;

  const mintedTokens: BigNumber = BigNumber.from((100 * 10 ** 18).toString());

  beforeEach(async function () {
    MetaToken = await ethers.getContractFactory("WrappedMeta");
    [owner, addr1, addr2] = await ethers.getSigners();
    wMetaToken = await MetaToken.deploy();

    await wMetaToken.mint(owner.address, mintedTokens);
    const ownerBalance = await wMetaToken.balanceOf(owner.address);
    expect(await wMetaToken.totalSupply()).to.equal(mintedTokens);
    expect(ownerBalance).to.equal(mintedTokens);
  });

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      expect(
        await wMetaToken.hasRole(await wMetaToken.MINTER_ROLE(), owner.address)
      ).to.equal(true);

      expect(
        await wMetaToken.hasRole(await wMetaToken.PAUSER_ROLE(), owner.address)
      ).to.equal(true);

      expect(
        await wMetaToken.hasRole(
          await wMetaToken.SNAPSHOT_ROLE(),
          owner.address
        )
      ).to.equal(true);
    });

    it("Should return false to the wrong owner", async function () {
      expect(
        await wMetaToken.hasRole(await wMetaToken.MINTER_ROLE(), addr1.address)
      ).to.equal(false);

      expect(
        await wMetaToken.hasRole(await wMetaToken.PAUSER_ROLE(), addr1.address)
      ).to.equal(false);

      expect(
        await wMetaToken.hasRole(
          await wMetaToken.SNAPSHOT_ROLE(),
          addr1.address
        )
      ).to.equal(false);
    });

    it("Should assign the total supply of tokens to the owner", async function () {
      const ownerBalance = await wMetaToken.balanceOf(owner.address);
      expect(await wMetaToken.totalSupply()).to.equal(ownerBalance);
    });
  });
  describe("Pausable", function () {
    it("Should not be paused by user who is not having the PAUSER_ROLE", async function () {
      await expect(wMetaToken.connect(addr1).pause()).to.be.revertedWith(
        `AccessControl: account ${addr1.address.toLowerCase()} is missing role ${await wMetaToken.PAUSER_ROLE()}`
      );
    });
    it("Should be paused only by the owner / by user who is having the PAUSER_ROLE", async function () {
      expect(await wMetaToken.connect(owner).pause());

      await expect(wMetaToken.connect(addr2).pause()).to.be.revertedWith(
        `AccessControl: account ${addr2.address.toLowerCase()} is missing role ${await wMetaToken.PAUSER_ROLE()}`
      );

      await wMetaToken
        .connect(owner)
        .grantRole(await wMetaToken.PAUSER_ROLE(), addr2.address);

      await expect(wMetaToken.connect(addr2).pause()).to.be.revertedWith(
        "Pausable: paused"
      );
    });
  });
  describe("Transactions", function () {
    it("Should transfer tokens between accounts", async function () {
      await wMetaToken.transfer(addr1.address, 50);
      const addr1Balance = await wMetaToken.balanceOf(addr1.address);
      expect(addr1Balance).to.equal(50);

      await wMetaToken.connect(addr1).transfer(addr2.address, 50);
      const addr2Balance = await wMetaToken.balanceOf(addr2.address);
      expect(addr2Balance).to.equal(50);
    });

    it("Should fail if sender doesn’t have enough tokens", async function () {
      const initialOwnerBalance: BigNumber = await wMetaToken.balanceOf(
        owner.address
      );

      await expect(
        wMetaToken
          .connect(addr1)
          .transfer(owner.address, mintedTokens.add(BigNumber.from(2)))
      ).to.be.revertedWith("ERC20: transfer amount exceeds balance");

      expect(await wMetaToken.balanceOf(owner.address)).to.equal(
        initialOwnerBalance
      );
    });

    it("Should update balances after transfers", async function () {
      const initialOwnerBalance = await wMetaToken.balanceOf(owner.address);

      await wMetaToken.transfer(addr1.address, 100);

      await wMetaToken.transfer(addr2.address, 50);

      const finalOwnerBalance = await wMetaToken.balanceOf(owner.address);
      expect(finalOwnerBalance).to.equal(initialOwnerBalance.sub(150));

      const addr1Balance = await wMetaToken.balanceOf(addr1.address);
      expect(addr1Balance).to.equal(100);

      const addr2Balance = await wMetaToken.balanceOf(addr2.address);
      expect(addr2Balance).to.equal(50);
    });
  });
});
