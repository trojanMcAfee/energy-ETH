const { ethers } = require('ethers');
const { formatUnits } = ethers.utils;
const { mine } = require("@nomicfoundation/hardhat-network-helpers");

const { diamondABI } = require('./state-vars');


async function deployContract(contractName, constrArgs) {
    let var1, var2, var3, var4;
    let contract;

    const Contract = await hre.ethers.getContractFactory(contractName);

    switch(contractName) {
        case 'ozOracleFacet':
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


async function getLastPrice(ozOracle, blockDifference_, num_) {
    let price = await ozOracle.getLastPrice();
    console.log(`eETH price ${num_}: `, formatUnits(price, 8));
    if (blockDifference_ !== '') await mine(blockDifference_);
}

async function addToDiamond(ozOracle) {
    const ozDiamondAddr = '0x7D1f13Dd05E6b0673DC3D0BFa14d40A74Cfa3EF2';
    const ozDiamond = await hre.ethers.getContractAt(diamondABI, ozDiamondAddr);

    const lastPriceSelector = ozOracle.interface.getSighash('getLastPrice');
    const facetCutArgs = [
        [ozOracle.address, 0, [lastPriceSelector] ]
    ];
    const tx = await ozDiamond.diamondCut(facetCutArgs, nullAddr, '0x');
    const receipt = await tx.wait();
    console.log('ozOracle added: ', receipt.transactionHash);


}





module.exports = {
    deployContract,
    callEeth,
    getLastPrice,
    addToDiamond
};