const hre = require("hardhat");
const { ethers } = require('ethers');
require('dotenv').config();

const { 
  mine, 
  impersonateAccount,
  stopImpersonatingAccount
} = require("@nomicfoundation/hardhat-network-helpers");

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
  const energyFacet = await deployContract('EnergyETH');
  
  //Add oracle to ozDiamond
  const feeds = [
    wtiFeedAddr,
    volatilityFeedAddr,
    ethUsdFeed,
    goldFeedAddr
  ];

  await addToDiamond(ozOracle, feeds);

  // Queries price
  for (let i=0; i < blockDiff.length; i++) {
    await getLastPrice(blockDiff[i], i);
  }

  // await getLastPrice(blockDiff[0], 0);

  //--------------------
  //For issuing

  // const ozDiamond = await hre.ethers.getContractAt(diamondABI, ozDiamondAddr);
  // const ePrice = await energyFacet.getPrice();

  // const holder = '0x62383739d68dd0f844103db8dfb05a7eded5bbe6';
  // const USDC = await hre.ethers.getContractAt('ERC20', '0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8');
  // const bal = await USDC.balanceOf(holder);

  // await sendETHOps(10, holder);
  // await impersonateAccount(holder);
  // const holderSign = await hre.ethers.provider.getSigner(holder);

  // const tx = await energyFacet.connect(holderSign).issue(wtiFeedAddr, 2, opsL2_2);
  // receipt = await tx.wait();

  // await stopImpersonatingAccount(holder);
}



main();



