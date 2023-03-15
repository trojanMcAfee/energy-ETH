const { reset, loadFixture, setCode, mine } = require("@nomicfoundation/hardhat-network-helpers");
const hre = require("hardhat");
const { ethers } = require('ethers');
require('dotenv').config();

const { 
  parseEther, 
  formatEther,
  formatUnits
} = require("ethers/lib/utils");


const { 
  wtiFeedAddr,
  volatilityFeedAddr,
  ethUsdFeed,
  blocks
} = require('../state-vars');

const { deployContract } = require('../helpers');




async function deploy() {
  const energyETH = await deployContract(
    'EnergyETHFacet',
    [wtiFeedAddr, volatilityFeedAddr, ethUsdFeed]
  );
  return energyETH;
}


async function main() {
  // const url = process.env.ARBITRUM;

  // await reset(url, 69254391);

  // const WtiFeed = await hre.ethers.getContractFactory('WtiFeed');
  // // const wtiBytecode = WtiFeed.bytecode;
  // const deployTx = await WtiFeed.getDeployTransaction();
  // await setCode(wtiFeedAddr, deployTx.data);

  const wtiFeed = await deployContract('WtiFeed');
  const wtiFeedAddr = wtiFeed.address;

  const energyETH = await deployContract(
    'EnergyETHFacet',
    [wtiFeedAddr, volatilityFeedAddr, ethUsdFeed]
  );

  let price = await energyETH.testFeed();
  console.log('price 0: ', formatUnits(price, 8));

  // let energyETH = await loadFixture(deploy);

  // const WtiFeed = await hre.ethers.getContractFactory('WtiFeed');
  // const wtiBytecode = WtiFeed.bytecode;
  // await setCode(wtiFeedAddr, wtiBytecode);
  

  await mine(1300);

  price = await energyETH.testFeed();
  console.log('price 1: ', formatUnits(price, 8));

  // await reset(url, blocks[1]);

  // energyETH = await loadFixture(deploy);


}




















// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
