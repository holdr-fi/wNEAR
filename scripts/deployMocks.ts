import { ethers } from 'hardhat';

async function main() {
  const MOCK_NEAR = await ethers.getContractFactory('MOCK_NEAR');
  const MOCK_WNEAR = await ethers.getContractFactory('MOCK_WNEAR');
  const mockNEAR = await MOCK_NEAR.deploy();
  await mockNEAR.deployed();
  console.log(`mockNEAR deployed to ${mockNEAR.address}`);
  const mockWNEAR = await MOCK_WNEAR.deploy(mockNEAR.address);
  await mockWNEAR.deployed();
  console.log(`mockWNEAR deployed to ${mockWNEAR.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
