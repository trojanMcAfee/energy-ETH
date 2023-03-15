const { ethers } = require('ethers');
const { formatUnits } = ethers.utils;
const { mine } = require("@nomicfoundation/hardhat-network-helpers");


async function deployContract(contractName, constrArgs) {
    let var1, var2, var3;
    let contract;

    const Contract = await hre.ethers.getContractFactory(contractName);

    switch(contractName) {
        case 'EnergyETHFacet':
            ([ var1, var2, var3 ] = constrArgs);
            contract = await Contract.deploy(var1, var2, var3);
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



module.exports = {
    deployContract,
    callEeth
};