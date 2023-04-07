import { ethers } from 'hardhat';

async function main() {
  // const WNEAR = await ethers.getContractFactory('WNEAR');
  // const wNEAR = await WNEAR.deploy();
  // await wNEAR.deployed();
  // console.log(`wNEAR deployed to ${wNEAR.address}`);
  const WNSTART = await ethers.getContractFactory('WNSTART');
  const wNSTART = await WNSTART.deploy();
  await wNSTART.deployed();
  console.log(`wNSTART deployed to ${wNSTART.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
