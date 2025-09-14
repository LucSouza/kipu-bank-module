// deploy on remix ide instead Hardhat scripts

async function deploy() {
  const KipuBank = await ethers.getContractFactory("KipuBank");
  const kipuBank = await KipuBank.deploy(
    ethers.parseEther("100"), // bankCap change before deploy if needed
    ethers.parseEther("1")    // maxWithdrawPerTx change before deploy if needed
  );
  console.log("Deployed to:", kipuBank.target);
}