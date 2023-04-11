// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import '@rari-capital/solmate/src/utils/FixedPointMathLib.sol';
import { DataInfo } from '../contracts/AppStorage.sol';


library LibHelpers {

    using FixedPointMathLib for uint256;

    int256 private constant EIGHT_DEC = 1e8;
    int256 private constant NINETN_DEC = 1e19;

    int constant BASE = 1e7;


    function calculateSlippage(
        uint256 amount_, 
        uint256 basisPoint_
    ) internal pure returns(uint256 minAmountOut) {
        minAmountOut = amount_ - amount_.mulDivDown(basisPoint_, 10000);
    }


    function getFee(uint256 amount_, uint256 protocolFee_) internal pure returns(uint, uint) {
        uint256 fee = amount_ - calculateSlippage(amount_, protocolFee_);
        uint256 netAmount = amount_ - fee;
        return (netAmount, fee);
    }

    //--------

    function getPrevFeed(
        uint80 roundId_, 
        AggregatorV3Interface feed_
    ) internal view returns(int256) {
        (,int256 prevPrice,,,) = feed_.getRoundData(roundId_ - 1);
        return prevPrice;
    }

    // function _setPrice(
    //     DataInfo memory price_, 
    //     int256 volIndex_, 
    //     AggregatorV3Interface feed_
    // ) private view returns(int256) {
    //     if (address(feed_) != address(s.ethFeed)) {
    //         int256 currPrice = price_.value;
    //         int256 netDiff = currPrice - _getPrevFeed(price_.roundId, feed_);
    //         return ( (netDiff * 100 * EIGHT_DEC) / currPrice ) * (volIndex_ / NINETN_DEC);
    //     } else {
    //         int256 prevEthPrice = _getPrevFeed(price_.roundId, feed_);
    //         int256 netDiff = price_.value - prevEthPrice;
    //         return (netDiff * 100 * EIGHT_DEC) / prevEthPrice;
    //     }
    // }

    function calculateBasePrice(int256 ethPrice_) internal pure returns(int256) {
        return ( (100 * EIGHT_DEC * ethPrice_) / 10 * EIGHT_DEC ) / BASE;
    }

}