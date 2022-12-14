import { ethers } from 'hardhat';

async function main() {
  const WNEAR = await ethers.getContractFactory('WNEAR');
  const wNEAR = await WNEAR.deploy();
  await wNEAR.deployed();
  console.log(`wNEAR deployed to ${wNEAR.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
