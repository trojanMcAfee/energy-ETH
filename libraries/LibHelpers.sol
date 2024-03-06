// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import '@rari-capital/solmate/src/utils/FixedPointMathLib.sol';
import { DataInfo } from '../contracts/AppStorage.sol';
import { UC, uc } from "unchecked-counter/UC.sol";



/**
 * @dev Library with main helper methods
 */
library LibHelpers {

    using FixedPointMathLib for uint256;

    int256 private constant EIGHT_DEC = 1e8;
    int256 private constant NINETN_DEC = 1e19;

    int constant BASE = 1e7;

    /*///////////////////////////////////////////////////////////////
                            ozExecutor2 helpers
    //////////////////////////////////////////////////////////////*/
    
    /**
     * @dev Calculates the slippage based on a defined tolerance.
     * @param amount_ main base amount.
     * @param basisPoint_ basis point of slippage tolerance. 
     * @return minAmountOut - minimum amount out for the trader to receive.
     */
    function calculateSlippage(
        uint256 amount_, 
        uint256 basisPoint_
    ) internal pure returns(uint256 minAmountOut) {
        minAmountOut = amount_ - amount_.mulDivDown(basisPoint_, 10000);
    }

    /**
     * @dev Charges the protocol fee.
     * @param amount_ total to extract the fee from.
     * @param protocolFee_ fee to be extracted.
     * @return (amount with fee deducted, protocol fee).
     */
    function getFee(uint256 amount_, uint256 protocolFee_) internal pure returns(uint, uint) {
        uint256 fee = amount_ - calculateSlippage(amount_, protocolFee_);
        uint256 netAmount = amount_ - fee;
        return (netAmount, fee);
    }



    /*///////////////////////////////////////////////////////////////
                            ozOracle helpers
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Gets the price of prior Chainlink price update.
     * @param roundId_ ID number of the previous price update. 
     * @param feed_ price feed to get the previous update from.
     * @return previous price. 
     */
    function getPrevFeed(
        uint80 roundId_, 
        AggregatorV3Interface feed_
    ) internal view returns(int256) {
        (,int256 prevPrice,,,) = feed_.getRoundData(roundId_ - 1);
        return prevPrice;
    }

    /**
     * @dev Formats ETHUSD precision from 8 decimals to 18.
     * @param ethPrice_ ETHUSD price formatted to 8 decimals.
     * @return ETHUSD price formatted to 18 decimals.
     */
    function formatLinkEth(int256 ethPrice_) internal pure returns(int256) {
        return ( (100 * EIGHT_DEC * ethPrice_) / 10 * EIGHT_DEC ) / BASE;
    }

    /**
     * @dev Gets the absolute value of a number.
     * @param num_ number.
     * @return absolue value of num_.
     */
    function abs(int256 num_) internal pure returns(int256) {
        return num_ >= 0 ? num_ : -num_;
    }

    /**
     * @dev Checks if the price difference between a previos and a
     * current update is below or above 5%. 
     * @param twap_ uniswap's TWAP current price for ETHUSD.
     * @param link_ chainlink's current price for ETHUSD.
     * @param prevLink_ chainlink's previous price for ETHUSD.
     */
    function checkEthDiff(
        int256 twap_, 
        int256 link_, 
        int256 prevLink_
    ) internal pure returns(bool) 
    {
        int256 prevDiff = twap_ - prevLink_;
        int256 diff = twap_ - link_;
        int256 PERCENTAGE_DIFF = 5;

        int256 prevPerDiff = (abs(prevDiff) * 100) / twap_;
        int256 perDiff = (abs(diff) * 100) / twap_;

        return perDiff > PERCENTAGE_DIFF ? prevPerDiff > PERCENTAGE_DIFF : false;
    }


    /*///////////////////////////////////////////////////////////////
                            ozCutFaceV2 helpers
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Common IndexOf() method. 
     * @param array_ array to query.
     * @param value_ address to find out if it's in array or not.
     * @return returns -1 or in the dex of value_ in array_.  
     */
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