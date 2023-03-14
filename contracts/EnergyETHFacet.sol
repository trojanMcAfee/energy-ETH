// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;


import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import 'solmate/src/utils/FixedPointMathLib.sol';

import 'hardhat/console.sol';

contract EnergyETHFacet is ERC20 {

    using FixedPointMathLib for uint;

    AggregatorV3Interface private wtiFeed;
    AggregatorV3Interface private volatilityFeed;
    AggregatorV3Interface private ethUsdFeed;

    int prevWtiPrice = 7474808000;
    uint prevVol = 0;
    int prevEthPrice = 161900260000;

    int currVol; 

    int EIGHT_DEC = 1e8;

    int eETHprice = 1000 * EIGHT_DEC;


    
    constructor(
        address wtiFeed_,
        address volatilityFeed_,
        address ethUsdFeed_
    ) ERC20('Energy ETH', 'eETH') {
        wtiFeed = AggregatorV3Interface(wtiFeed_);
        volatilityFeed = AggregatorV3Interface(volatilityFeed_);
        ethUsdFeed = AggregatorV3Interface(ethUsdFeed_);
    }


    function getPrice() public returns(uint wtiPrice, uint volPrice, uint ethPrice) {
        (wtiPrice, volPrice, ethPrice) = _getFeeds();

        return (wtiPrice, volPrice, ethPrice);
    }

    function _getDataFeeds() private view returns(int, int, int) {
        (,int volatility,,,) = volatilityFeed.latestRoundData();
        (,int wtiPrice,,,) = wtiFeed.latestRoundData();
        (,int ethPrice,,,) = ethUsdFeed.latestRoundData();

        return (volatility, wtiPrice, ethPrice);
    }

    function _getFeeds() private returns(uint, uint, uint) {
        // (int volatility, int wtiPrice, int ethPrice) = _getDataFeeds();
        (,int volatility,,,) = volatilityFeed.latestRoundData();

        (,int wtiPrice,,,) = wtiFeed.latestRoundData();
        int implWti2 = _setImplWti(wtiPrice, volatility); 

        (,int ethPrice,,,) = ethUsdFeed.latestRoundData();
        int implEth = _setImplEth(ethPrice);

        int netDiff = implWti2 + implEth;

        eETHprice = eETHprice + ( (netDiff * eETHprice) / (100 * EIGHT_DEC) );
        console.log(uint(eETHprice));


 
        return (
            1,
            2,
            3
        );
    }




    // function _setVolIndex(int newVal_) private returns(int) {
    //     if (newVal_ == currVol) {
    //         return currVol;
    //     } else {
    //         currVol = newVal_;
    //         return currVol;
    //     }
    // }

 
    function _setImplWti(int currWti_, int currVol_) private view returns(int) {
        int netDiff = currWti_ - prevWtiPrice;
        return ( (netDiff * 100 * EIGHT_DEC) / currWti_ ) * (currVol_ / 1e19);
    }

    function _setImplEth(int currEth_) private view returns(int) {
        int netDiff2 = currEth_ - prevEthPrice;
        return (netDiff2 * 100 * EIGHT_DEC) / prevEthPrice;
    }


}


