// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {

  const Refound = await ethers.getContractFactory("Refound");
  const refound = await Refound.deploy();
  const RefoundPost = await ethers.getContractFactory("RefoundPost");
  const refoundPost = await RefoundPost.deploy(refound.address);
  await refound.changeAddresses(refoundPost.address);
  await refound.deployed();
  await refoundPost.deployed();

  console.log(
    `Refound contract deployed to ${refound.address} and RefoundPost contract deployed to ${refoundPost.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
