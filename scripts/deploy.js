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
  goldFeedAddr,
  diamondABI,
  opsL2_2,
  deployer2,
  ozDiamondAddr
} = require('../state-vars');

const { 
  deployContract, 
  getLastPrice,
  addToDiamond,
  sendETHOps
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

  // Queries price
  // for (let i=0; i < blockDiff.length; i++) {
  //   await getLastPrice(blockDiff[i], i);
  // }

  // await getLastPrice(blockDiff[0], 0);c

  const ozDiamond = await hre.ethers.getContractAt(diamondABI, ozDiamondAddr);
  const ePrice = await ozDiamond.getPrice();
  console.log('energy price: ', formatEther(ePrice));
}

// main();


async function testGanacheFeed() {
  const wtiFeedAddr = '0x1dC4c1cEFEF38a777b15aA20260a54E584b16C48';
  const abi = ['function latestRoundData() external view returns(int256, int256, int256, int256, int256)'];
  const wtiFeed = await hre.ethers.getContractAt(abi, wtiFeedAddr);

  // const privateKey = process.env.DEPLOYER2;
  // const provider = new ethers.providers.JsonRpcProvider('http://127.0.0.1:8546');
  // const wallet = new ethers.Wallet(privateKey, provider);

  const price = await wtiFeed.latestRoundData();
  console.log('price: ', price);
}

// testGanacheFeed();



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


async function checkAirdrop() {
  const abi = ['function claimableTokens(address) external returns(uint256)'];
  const arbAddr = '0x67a24CE4321aB3aF51c2D0a4801c3E111D88C9d9';
  const arb = await hre.ethers.getContractAt(abi, arbAddr);
  const addr = '0x938Dc5298D505B06B5Ba542e461c665923eD0519';

  const bal = await arb.claimableTokens(addr);
  console.log('bal: ', Number(bal));

}

// checkAirdrop();


async function callRpc() {
  const ozDiamondAddr = '0x7D1f13Dd05E6b0673DC3D0BFa14d40A74Cfa3EF2';
  const ozDiamond = await hre.ethers.getContractAt(diamondABI, ozDiamondAddr);

  const privateKey = process.env.DEPLOYER2;
  const provider = new ethers.providers.JsonRpcProvider('http://127.0.0.1:8546');
  const wallet = new ethers.Wallet(privateKey, provider);

  // const tx = await ozDiamond.connect(wallet).diamondCut(facetCutArgs, init.address, initData, opsL2_2);
  const owner = await ozDiamond.connect(wallet).owner();
  console.log('owner: ', owner);

}

// callRpc();


async function tryEnergy() {
  const ozDiamond = await hre.ethers.getContractAt(diamondABI, ozDiamondAddr);
  ozDiamond.interface.encodeFunctionData()


}


// getAddr();

main();



