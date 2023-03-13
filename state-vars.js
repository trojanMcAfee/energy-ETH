

let wtiFeedAddr;
let volatilityFeedAddr;
let ethUsdFeed;



let network = 'arbitrum';
switch(network) {
case 'arbitrum':
    wtiFeedAddr = '0x594b919AD828e693B935705c3F816221729E7AE8';
    volatilityFeedAddr = '0xbcD8bEA7831f392bb019ef3a672CC15866004536';
    ethUsdFeed = '0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612';
    break;
case 'mainnet':
    wtiFeedAddr = '0xf3584F4dd3b467e73C2339EfD008665a70A4185c';
    volatilityFeedAddr = '0x1B58B67B2b2Df71b4b0fb6691271E83A0fa36aC5';
    ethUsdFeed = '0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419';
}



module.exports = {
    wtiFeedAddr,
    volatilityFeedAddr,
    ethUsdFeed
};