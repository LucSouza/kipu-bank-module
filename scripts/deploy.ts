import { ethers } from "hardhat";

async function main() {
  const BANK_CAP = ethers.utils.parseEther("1000"); // example
  const MAX_WITHDRAW = ethers.utils.parseEther("1");

  const Kipu = await ethers.getContractFactory("KipuBank");
  const kipu = await Kipu.deploy(BANK_CAP, MAX_WITHDRAW);
  await kipu.deployed();
  console.log("KipuBank deployed to:", kipu.address);
}

main().catch((e)=>{ console.error(e); process.exit(1); });