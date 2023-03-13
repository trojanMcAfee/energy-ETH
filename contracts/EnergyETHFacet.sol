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

    uint prevWtiPrice = 7474808000;
    uint prevVol = 0;
    int prevEthPrice = 161900260000;

    uint currVol; 

    uint startPrice = 1000;

    
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

    function _getFeeds() private returns(uint, uint, uint) {
        // uint implWti;
        // uint implVol;
        // uint implEth;

        (,int volatility,,,) = volatilityFeed.latestRoundData();
        uint implVol2 = _setVolIndex(uint(volatility));

        (,int wtiPrice,,,) = wtiFeed.latestRoundData();
        uint implWti2 = _setImplWti(uint(wtiPrice), uint(volatility)); //currVol
        console.log('implWti: ', implWti2);


        (,int ethPrice,,,) = ethUsdFeed.latestRoundData();
        _setImplEth(ethPrice);

        // uint implWti = _setImplPrice(uint(wtiPrice), prevWtiPrice);
        // uint implVol = _setImplPrice(uint(volatility), prevVol);
        // uint implEth = _setImplPrice(uint(ethPrice), prevEthPrice);

 
        return (
            1,
            2,
            3
        );
    }


    // function _setImplPrice(uint curr_, uint prev_) private returns(uint implPrice) {
    //     if (curr_ > prev_) {
    //         implPrice = curr_;
    //     } else if (curr_ <= prev_) {
    //         implPrice = prev_;
    //     }
    // }

    function _setVolIndex(uint newVal_) private returns(uint) {
        if (newVal_ == currVol) {
            return currVol;
        } else {
            currVol = newVal_;
            return currVol;
        }
    }

 
    function _setImplWti(uint currWti_, uint currVol_) private view returns(uint) {
        uint netDiff = currWti_ - prevWtiPrice;
        // if (netDiff <= 0) return 0;
        return netDiff.mulDivDown(100 * 1e8, currWti_) * (currVol_ / 1e19);
    }

    function _setImplEth(int currEth_) private view returns(uint) {
        int netDiff = currEth_ - prevEthPrice;
        console.log(uint(int(0) - netDiff));
        console.log('^^^^');
    }



}


// currWti --- 100%
// netDiff ----- x