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
  blocks,
  goldFeedAddr
} = require('../state-vars');

const { 
  deployContract, 
  getLastPrice,
  addToDiamond
} = require('../helpers');



async function main() {

  //Deploy oracle
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

  const ethFeed = await deployContract('EthFeed');
  const ethUsdFeed = ethFeed.address;

  const goldFeed = await deployContract('GoldFeed');
  const goldFeedAddr = goldFeed.address;

  const ozOracle = await deployContract('ozOracleFacet');
  const energyFacet = await deployContract('EnergyETHFacet');
  
  //Add oracle to ozDiamond
  const feeds = [
    wtiFeedAddr,
    volatilityFeedAddr,
    ethUsdFeed,
    goldFeedAddr
  ];

  await addToDiamond(ozOracle, energyFacet, feeds);

  //Queries price
  for (let i=0; i < blockDiff.length; i++) {
    await getLastPrice(blockDiff[i], i);
  }
}

main();



async function main2() {

  const energyETH = await deployContract(
    'EnergyETHFacet',
    [wtiFeedAddr, volatilityFeedAddr, ethUsdFeed]
  );

  let price = await energyETH.testFeed();
  console.log('price 0: ', formatUnits(price, 8));


}




async function testGold() {
  const goldFeed = await hre.ethers.getContractAt('AggregatorV3Interface', goldFeedAddr);
  
  const [a,price,b,c,d] = await goldFeed.latestRoundData();
  console.log('price: ', Number(price));


}

// testGold();