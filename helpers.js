



async function deployContract(contractName, constrArgs) {
    let var1, var2, var3;
    let contract;

    const Contract = await hre.ethers.getContractFactory(contractName);

    switch(contractName) {
        case 'EnergyETHFacet':
            ([ var1, var2, var3 ] = constrArgs);
            contract = await Contract.deploy(var1, var2, var3);
            break;
    }


    await contract.deployed();
    console.log(`${contractName} deployed to: `, contract.address);

    return contract;
}



module.exports = {
    deployContract
};