// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import '@rari-capital/solmate/src/utils/FixedPointMathLib.sol';
import { DataInfo } from '../contracts/AppStorage.sol';
import { UC, uc } from "unchecked-counter/UC.sol";

import "forge-std/console.sol";


library LibHelpers {

    using FixedPointMathLib for uint256;

    int256 private constant EIGHT_DEC = 1e8;
    int256 private constant NINETN_DEC = 1e19;

    int constant BASE = 1e7;

    //ozExecutor2 helpers
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

    //ozOracle Helpers
    function getPrevFeed(
        uint80 roundId_, 
        AggregatorV3Interface feed_
    ) internal view returns(int256) {
        (,int256 prevPrice,,,) = feed_.getRoundData(roundId_ - 1);
        return prevPrice;
    }

    function formatLinkEth(int256 ethPrice_) internal pure returns(int256) {
        return ( (100 * EIGHT_DEC * ethPrice_) / 10 * EIGHT_DEC ) / BASE;
    }

    function abs(int256 num_) internal pure returns(int256) {
        return num_ >= 0 ? num_ : -num_;
    }

    function checkEthDiff(
        int256 twap_, 
        int256 link_, 
        int256 prevLink_
    ) internal view returns(bool) 
    {
        int256 prevDiff = twap_ - prevLink_;
        int256 diff = twap_ - link_;
        int256 PERCENTAGE_DIFF = 5;

        // console.logInt(twap_ - prevLink_);
        // console.log('diff: ', uint(diff));
        // console.log('');

        // console.log('twap: ', uint(twap_));
        // console.log('link: ', uint(link_));
        // console.log('prevLink: ', uint(prevLink_));

        int256 prevPerDiff = (abs(prevDiff) * 100) / twap_;
        int256 perDiff = (abs(diff) * 100) / twap_;

        // console.logInt(prevPerDiff);
        // console.log('perDiff: ', uint(perDiff));

        return perDiff > PERCENTAGE_DIFF ? prevPerDiff > PERCENTAGE_DIFF : false;
    }

    //--------
    //ozCutFaceV2 helpers


    // function indexOf(
    //     address[] calldata array_, 
    //     address value_
    // ) internal pure returns(int256) 
    // {
    //     uint256 length = array_.length;
    //     for (UC i=uc(0); i < uc(length); i = i + uc(1)) {
    //         uint256 ii = i.unwrap();
            
    //         if (array_[ii] == value_) {
    //             return int256(ii);
    //         }
    //     }
    //     return -1;
    // }

    function indexOf(
        AggregatorV3Interface[] memory array_, 
        address value_
    ) internal pure returns(int256) 
    {
        uint256 length = array_.length;
        for (UC i=uc(0); i < uc(length); i = i + uc(1)) {
            uint256 j = i.unwrap();
            if (address(array_[j]) == value_) return int256(j);
        }
        return -1;
    }

}