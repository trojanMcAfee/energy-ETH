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

const { deployContract, callEeth } = require('../helpers');






async function main() {

  const blockDiff = [
    1300,
    5000, 
    34000,
    1000,
    2000,
    83000,
    41000,
    ''
  ];

  const wtiFeed = await deployContract('WtiFeed');
  const wtiFeedAddr = wtiFeed.address;

  const ethFeed = await deployContract('EthUsdFeed');
  const ethUsdFeed = ethFeed.address;

  const energyETH = await deployContract(
    'EnergyETHFacet',
    [wtiFeedAddr, volatilityFeedAddr, ethUsdFeed]
  );
  //------

  for (let i=0; i < blockDiff.length; i++) {
    // let diff = blockDiff[i];
    // if (diff === null) diff = '';
    await callEeth(energyETH, blockDiff[i], i);
  }

  // await callEeth(energyETH, 1300, 0);
  // await callEeth(energyETH, 5000, 1);
  // await callEeth(energyETH, 34000, 2);
  // await callEeth(energyETH, 1000, 3);
  // await callEeth(energyETH, 2000, 4);
  // await callEeth(energyETH, 83000, 5);
  // await callEeth(energyETH, 41000, 6);
  // await callEeth(energyETH, '', 7);

}



async function main2() {

  const energyETH = await deployContract(
    'EnergyETHFacet',
    [wtiFeedAddr, volatilityFeedAddr, ethUsdFeed]
  );

  let price = await energyETH.testFeed();
  console.log('price 0: ', formatUnits(price, 8));


}
















// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
