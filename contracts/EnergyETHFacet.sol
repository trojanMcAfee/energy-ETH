// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import 'solmate/src/utils/FixedPointMathLib.sol';

import 'hardhat/console.sol';

contract EnergyETHFacet is ERC20 {

    using FixedPointMathLib for uint;

    AggregatorV3Interface private wtiFeed;
    AggregatorV3Interface private volatilityFeed;
    AggregatorV3Interface private ethFeed;
    AggregatorV3Interface private goldFeed;

    int EIGHT_DEC = 1e8;
    int NINETN_DEC = 1e19;

    int eETHprice = 1000 * EIGHT_DEC;


    struct DataInfo {
        uint80 roundId;
        int value;
    }

    struct Data {
        DataInfo volIndex;
        DataInfo wtiPrice;
        DataInfo ethPrice;
        DataInfo goldPrice;
    }


    
    constructor(
        address wtiFeed_,
        address volatilityFeed_,
        address ethUsdFeed_,
        address goldFeed_
    ) ERC20('Energy ETH', 'eETH') {
        wtiFeed = AggregatorV3Interface(wtiFeed_);
        volatilityFeed = AggregatorV3Interface(volatilityFeed_);
        ethFeed = AggregatorV3Interface(ethUsdFeed_);
        goldFeed = AggregatorV3Interface(goldFeed_);
    }



    function _getDataFeeds() private view returns(Data memory data) {
        (,int volatility,,,) = volatilityFeed.latestRoundData();
        (uint80 wtiId, int wtiPrice,,,) = wtiFeed.latestRoundData();
        (uint80 ethId, int ethPrice,,,) = ethFeed.latestRoundData();
        (uint80 goldId, int goldPrice,,,) = goldFeed.latestRoundData();

        data = Data({
            volIndex: DataInfo({
                roundId: 0,
                value: volatility
            }),
            wtiPrice: DataInfo({
                roundId: wtiId,
                value: wtiPrice
            }),
            ethPrice: DataInfo({
                roundId: ethId,
                value: ethPrice
            }),
            goldPrice: DataInfo({
                roundId: goldId,
                value: goldPrice
            })
        });
    }


    //**** MAIN ******/
    function getLastPrice() external view returns(uint) {
        Data memory data = _getDataFeeds();
        int volIndex = data.volIndex.value;

        int implWti = _setImplWti(data.wtiPrice, volIndex, wtiFeed); 
        int implGold = _setImplGold(data.goldPrice, volIndex, goldFeed);
        int implEth = _setImplEth(data.ethPrice, ethFeed);

        int netDiff = implWti + implEth + implGold;

        return uint(eETHprice + ( (netDiff * eETHprice) / (100 * EIGHT_DEC) ));
    }


     function _getPrevFeed(
        uint80 roundId_, 
        AggregatorV3Interface feed_
    ) private view returns(int) {
        (,int prevPrice,,,) = feed_.getRoundData(roundId_ - 1);
        return prevPrice;
    }

    function _setImplWti(
        DataInfo memory wtiPrice_,
        int volIndex_,
        AggregatorV3Interface feed_
    ) private view returns(int) {
        int currWti = wtiPrice_.value;
        int netDiff = currWti - _getPrevFeed(wtiPrice_.roundId, feed_);
        return ( (netDiff * 100 * EIGHT_DEC) / currWti ) * (volIndex_ / NINETN_DEC);
    }


    function _setImplGold(
        DataInfo memory goldPrice_,
        int volIndex_,
        AggregatorV3Interface feed_
    ) private view returns(int) {
        int currGold = goldPrice_.value;

        int netDiff = currGold - _getPrevFeed(goldPrice_.roundId, feed_);
        return ( (netDiff * 100 * EIGHT_DEC) / currGold ) * (volIndex_ / NINETN_DEC);
    }


    function _setImplEth(
        DataInfo memory ethPrice_,
        AggregatorV3Interface feed_
    ) private view returns(int) {
        int prevEthPrice = _getPrevFeed(ethPrice_.roundId, feed_);
        int netDiff = ethPrice_.value - prevEthPrice;
        return (netDiff * 100 * EIGHT_DEC) / prevEthPrice;
    }


}


