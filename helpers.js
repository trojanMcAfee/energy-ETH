const { ethers } = require('ethers');
const { 
    formatUnits, 
    parseEther, 
    formatEther 
} = ethers.utils;
const { 
    mine, 
    impersonateAccount,
    stopImpersonatingAccount
 } = require("@nomicfoundation/hardhat-network-helpers");

const { 
    diamondABI, 
    ozDiamondAddr,
    deployer2,
    opsL2_2
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


async function sendETHOps(amount, receiver) {
    const [signer] = await hre.ethers.getSigners();
    let balance = await signer.getBalance();
    // console.log('addr: ', await signer.getAddress());
    
    tx = await signer.sendTransaction({
        value: parseEther(amount.toString()),
        to: receiver
    });
    await tx.wait();

    balance = await signer.getBalance();
}



async function getLastPrice(blockDifference_, num_) {
    const ozDiamond = await hre.ethers.getContractAt(diamondABI, ozDiamondAddr);
    let price = await ozDiamond.getLastPrice();
    console.log(`eETH price ${num_}: `, formatUnits(price, 18));
    if (blockDifference_ !== '') await mine(blockDifference_);
}



async function addToDiamond(ozOracle, energyFacet, feeds) {
    const ozDiamond = await hre.ethers.getContractAt(diamondABI, ozDiamondAddr);

    const lastPriceSelector = ozOracle.interface.getSighash('getLastPrice');
    const energyPriceSelector = energyFacet.interface.getSighash('getEnergyPrice');
    const facetCutArgs = [
        [ozOracle.address, 0, [lastPriceSelector] ],
        [energyFacet.address, 0, [energyPriceSelector]]
    ];
    const facetAddresses = [
        ozOracle.address,
        energyFacet.address
    ];

    const init = await deployContract('InitUpgradeV2');
    const initData = init.interface.encodeFunctionData('init', [
        feeds,
        facetAddresses
    ]);

    await sendETHOps(1, deployer2);

    //-------

    const privateKey = process.env.DEPLOYER2;
    const provider = new ethers.providers.JsonRpcProvider('http://127.0.0.1:8546');
    const wallet = new ethers.Wallet(privateKey, provider);

    // const [signer] = await hre.ethers.getSigners();
    // const signerAddr = await signer.getAddress();
    // console.log('signer: ', signerAddr);
    // console.log('wallet: ', await wallet.getAddress());

    const tx = await ozDiamond.connect(wallet).diamondCut(facetCutArgs, init.address, initData, opsL2_2);

    // const cutData = ozDiamond.interface.encodeFunctionData('diamondCut', [
    //     facetCutArgs, init.address, initData
    // ]);
    // console.log('cutData: ', cutData); 

    // const rawTx = {
    //     to: ozDiamond.address,
    //     data: cutData
    // };

    // const tx = await wallet.sendTransaction(rawTx);
    const receipt = await tx.wait();
    console.log('ozOracle added to ozDiamond: ', receipt.transactionHash);

    const index = await ozDiamond.getOzelIndex();
    console.log('ozel index: ',formatEther(index) );

    // const price = ozDiamond.connect(wallet).getLastPrice();
    // console.log('price: ', Number(price));


}





module.exports = {
    deployContract,
    getLastPrice,
    addToDiamond,
    sendETHOps
};