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



// async function callEeth(energyETH_, blockDifference_) {
//   let price = await energyETH_.testFeed();
//   console.log('price 0: ', formatUnits(price, 8));

//   price = await energyETH_.testFeed2();
//   console.log('eth price 0: ', formatUnits(price, 8));
//   console.log('.');

//   await mine(blockDifference_);
// }




async function main() {

  const wtiFeed = await deployContract('WtiFeed');
  const wtiFeedAddr = wtiFeed.address;

  const ethFeed = await deployContract('EthUsdFeed');
  const ethUsdFeed = ethFeed.address;

  const energyETH = await deployContract(
    'EnergyETHFacet',
    [wtiFeedAddr, volatilityFeedAddr, ethUsdFeed]
  );
  //------

  // let price = await energyETH.testFeed();
  // console.log('price 0: ', formatUnits(price, 8));

  // price = await energyETH.testFeed2();
  // console.log('eth price 0: ', formatUnits(price, 8));
  // console.log('.');

  // await mine(1300);

  await callEeth(energyETH, 1300, 0);

  // price = await energyETH.testFeed();
  // console.log('price 1: ', formatUnits(price, 8));

  // price = await energyETH.testFeed2();
  // console.log('eth price 1: ', formatUnits(price, 8));
  // console.log('.');

  await callEeth(energyETH, 5000, 1);
  // await mine(5000);

  // price = await energyETH.testFeed();
  // console.log('price 2: ', formatUnits(price, 8));

  // price = await energyETH.testFeed2();
  // console.log('eth price 2: ', formatUnits(price, 8));
  // console.log('.');

  await callEeth(energyETH, 34000, 2);
  // await mine(34000);

  // price = await energyETH.testFeed();
  // console.log('price 3: ', formatUnits(price, 8));

  // price = await energyETH.testFeed2();
  // console.log('eth price 3: ', formatUnits(price, 8));
  // console.log('.');

  await callEeth(energyETH, 1000, 3);
  // await mine(1000);

  // price = await energyETH.testFeed();
  // console.log('price 4: ', formatUnits(price, 8));

  // price = await energyETH.testFeed2();
  // console.log('eth price 4: ', formatUnits(price, 8));
  // console.log('.');

  await callEeth(energyETH, 2000, 4);
  // await mine(2000);

  // price = await energyETH.testFeed();
  // console.log('price 5: ', formatUnits(price, 8));

  // price = await energyETH.testFeed2();
  // console.log('eth price 5: ', formatUnits(price, 8));
  // console.log('.');

  await callEeth(energyETH, 83000, 5);
  // await mine(83000);

  // price = await energyETH.testFeed();
  // console.log('price 6: ', formatUnits(price, 8));

  // price = await energyETH.testFeed2();
  // console.log('eth price 6: ', formatUnits(price, 8));
  // console.log('.');

  await callEeth(energyETH, 41000, 6);
  // await mine(41000);

  // price = await energyETH.testFeed();
  // console.log('price 7: ', formatUnits(price, 8));

  // price = await energyETH.testFeed2();
  // console.log('eth price 7: ', formatUnits(price, 8));
  // console.log('.');

  await callEeth(energyETH, '', 7);

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
