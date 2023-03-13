const hre = require("hardhat");
const { ethers } = require('ethers');

const { 
  parseEther, 
  formatEther,
  formatUnits
} = require("ethers/lib/utils");


const { 
  wtiFeedAddr,
  volatilityFeedAddr,
  ethUsdFeed
} = require('../state-vars');

const { deployContract } = require('../helpers');


async function main2() {
  const setTokenCreatorAddr = '0xeF72D3278dC3Eba6Dc2614965308d1435FFd748a';
  const navModuleAddr = '0xaB9a964c6b95fA529CA7F27DAc1E7175821f2334';
  const nullAddr = '0x0000000000000000000000000000000000000000';
  const wethAddr = '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2';
  const usdcAddr = '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48';
  const setValuerAddr = '0xDdF4F0775fF69c73619a4dBB42Ba61b0ac1F555f';

  const [signer] = await hre.ethers.getSigners();
  const signerAddr = await signer.getAddress();

  const SetTokenCreator = await hre.ethers.getContractFactory('CreateSet');
  const setTokenCreator = await SetTokenCreator.deploy(
    setTokenCreatorAddr, navModuleAddr
  );
  await setTokenCreator.deployed();
  console.log('CreateSet deployed to: ', setTokenCreator.address);

  let tx = await setTokenCreator.createSet();
  await tx.wait();
  
  //-------
  //Initialize set
  const setTokenAddr = await setTokenCreator.setToken();
  const E1016 = ethers.BigNumber.from('10000000000000000');
  const E515 = ethers.BigNumber.from('5000000000000000');

  const reserveAssets = [ wethAddr, usdcAddr ];
  const managerFees = [ E1016, E1016 ];
  const maxManagerFee = E1016;
  const premiumPercentage = E515;
  const maxPremiumPercentage = E515;
  const minSetTokenSupply = 5;

  const navConfig = [
    nullAddr,
    nullAddr,
    reserveAssets,
    signerAddr,
    managerFees,
    maxManagerFee,
    premiumPercentage,
    maxPremiumPercentage,
    minSetTokenSupply
  ];

  const navModule = await hre.ethers.getContractAt('INavModule', navModuleAddr);
  await navModule.initialize(setTokenAddr, navConfig);
  console.log('done init nav module');

  //-------
  //Issues set
  const setToken = await hre.ethers.getContractAt('ISetToken', setTokenAddr);
  let setBalance = await setToken.balanceOf(signerAddr);
  console.log('set bal pre: ', formatEther(setBalance));

  let ethBalance = await hre.ethers.provider.getBalance(signerAddr);
  console.log('eth bal: ', formatEther(ethBalance));

  // tx = await navModule.issueWithEther(setTokenAddr, 0, signerAddr, {
  //   value: parseEther('1')
  // });
  // await tx.wait();

  const setValuer = await hre.ethers.getContractAt('ISetValuer', setValuerAddr);
  const value = await setValuer.calculateSetTokenValuation(setTokenAddr, usdcAddr);
  console.log('val: ', formatEther(value));

  
  // setBalance = await setToken.balanceOf(signerAddr);
  // console.log('set bal post: ', formatEther(setBalance));




}



async function main() {
  

  // const EnergyETH = await hre.ethers.getContractFactory('EnergyETHFacet');
  // const energyETH = await EnergyETH.deploy(wtiFeedAddr, volatilityFeedAddr, ethUsdFeed);
  // await energyETH.deployed();
  // console.log('EnergyETHFacet deployed to: ', energyETH.address);

  const energyETH = await deployContract(
    'EnergyETHFacet',
    [wtiFeedAddr, volatilityFeedAddr, ethUsdFeed]
  );

  const [ oil, volatility, ethUsd ] = await energyETH.getPrice();
  console.log('oil price: ', formatUnits(oil, 8));
  console.log('volatility: ', formatEther(volatility));
  console.log('eth price: ', formatUnits(ethUsd, 8));

}




















// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
