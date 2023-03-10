const hre = require("hardhat");





async function main() {
  const setTokenCreatorAddr = '0xeF72D3278dC3Eba6Dc2614965308d1435FFd748a';
  const navModuleAddr = '0xaB9a964c6b95fA529CA7F27DAc1E7175821f2334';

  const SetTokenCreator = await hre.ethers.getContractFactory('CreateSet');
  const setTokenCreator = await SetTokenCreator.deploy(
    setTokenCreatorAddr, navModuleAddr
  );
  await setTokenCreator.deployed();
  console.log('CreateSet deployed to: ', setTokenCreator.address);

  await setTokenCreator.createNInit();
}
























// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
