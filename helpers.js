const { ethers } = require('ethers');
const { formatUnits } = ethers.utils;
const { 
    mine, 
    impersonateAccount,
    stopImpersonatingAccount
 } = require("@nomicfoundation/hardhat-network-helpers");

const { 
    diamondABI, 
    ozDiamondAddr,
    deployer2
} = require('./state-vars');


async function deployContract(contractName, constrArgs) {
    let var1, var2, var3, var4;
    let contract;

    const Contract = await hre.ethers.getContractFactory(contractName);

    switch(contractName) {
        case null:
            ([ var1, var2, var3, var4 ] = constrArgs);
            contract = await Contract.deploy(var1, var2, var3, var4);
            break;
        default:
            contract = await Contract.deploy();
    }


    await contract.deployed();
    console.log(`${contractName} deployed to: `, contract.address);

    return contract;
}


async function callEeth(energyETH_, blockDifference_, num_) {
    let price = await energyETH_.testFeed();
    console.log(`price ${num_}: `, formatUnits(price, 8));

    price = await energyETH_.testFeed2();
    console.log(`eth price ${num_}: `, formatUnits(price, 8));
    console.log('.');

    if (blockDifference_ !== '') await mine(blockDifference_);
}


async function getLastPrice(blockDifference_, num_) {
    const ozDiamond = await hre.ethers.getContractAt(diamondABI, ozDiamondAddr);
    let price = await ozDiamond.getLastPrice();
    console.log(`eETH price ${num_}: `, formatUnits(price, 18));
    if (blockDifference_ !== '') await mine(blockDifference_);
}



async function addToDiamond(ozOracle, feeds) {
    const ozDiamond = await hre.ethers.getContractAt(diamondABI, ozDiamondAddr);

    const lastPriceSelector = ozOracle.interface.getSighash('getLastPrice');
    const facetCutArgs = [
        [ozOracle.address, 0, [lastPriceSelector] ]
    ];

    const init = await deployContract('InitUpgradeV2');
    const initData = init.interface.encodeFunctionData('init', [
        feeds,
        ozOracle.address
    ]);

    await impersonateAccount(deployer2);
    const deployerSigner = await hre.ethers.provider.getSigner(deployer2);

    const tx = await ozDiamond.connect(deployerSigner).diamondCut(facetCutArgs, init.address, initData);
    const receipt = await tx.wait();
    console.log('ozOracle added to ozDiamond: ', receipt.transactionHash);

    await stopImpersonatingAccount(deployer2);
}





module.exports = {
    deployContract,
    callEeth,
    getLastPrice,
    addToDiamond
};