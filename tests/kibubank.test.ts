import { expect } from "chai";
import { ethers } from "hardhat";
import "@nomicfoundation/hardhat-chai-matchers";

describe("KipuBank", function () {
  it("should revert if deposit is 0", async function () {
    const [owner] = await ethers.getSigners();
    const KipuBank = await ethers.getContractFactory("KipuBank");
    const kipuBank = await KipuBank.deploy(ethers.parseEther("10"), ethers.parseEther("1"));
    await kipuBank.waitForDeployment();

    await expect(
      kipuBank.deposit({ value: 0 })
    ).to.be.revertedWithCustomError(kipuBank, "AmountZero");
  });
});
