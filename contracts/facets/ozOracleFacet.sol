// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import { UC, ONE, ZERO } from "unchecked-counter/UC.sol";
import '../AppStorage.sol';
import "forge-std/console.sol";
import '../../libraries/LibHelpers.sol';
import '../../libraries/LibDiamond.sol';
import '../../libraries/LibCommon.sol';
import '../../Errors.sol';
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';
// import '@uniswap/v3-periphery/contracts/libraries/OracleLibrary.sol';
import '../../libraries/oracle/OracleLibrary.sol';
import '../../libraries/oracle/FullMath.sol';
import "@uniswap/v3-core/contracts/libraries/FixedPoint96.sol";

// import 'hardhat/console.sol';

//add modularity to add and remove chainlink feeds
//add uniswap and trellors oracles as a fallback
contract ozOracleFacet {

    AppStorage s;

    using LibHelpers for *;

    int256 private constant EIGHT_DEC = 1e8;
    int256 private constant NINETN_DEC = 1e19;

    // error NotFeed(address feed);

    //**** MAIN ******/

    function getEnergyPrice() external view returns(uint256) {

        ( 
            DataInfo[] memory infoFeeds, 
            int256 basePrice, 
            int256 prevEth 
        ) = _getDataFeeds();

        // int256 basePrice = linkEth.getBasePrice(twapEth);
      
        int256 volIndex = getVolatilityIndex();
        int256 netDiff;

        uint256 length = infoFeeds.length;
        for (UC i=ZERO; i < uc(length); i = i + ONE) {
            DataInfo memory info = infoFeeds[i.unwrap()];

            netDiff += _setPrice(
                info, address(info.feed) == address(s.ethFeed) ? int256(0) : volIndex, prevEth
            );
        }

        return uint256(basePrice + ( (netDiff * basePrice) / (100 * EIGHT_DEC) ));
    }



    function _getDataFeeds() private view returns(DataInfo[] memory, int256, int256) {
        uint256 length = s.priceFeeds.length;
        DataInfo[] memory infoFeeds = new DataInfo[](length);

        for (UC i=ZERO; i < uc(length); i = i + ONE) {
            uint256 j = i.unwrap();
            (uint80 id, int256 value,,,) = s.priceFeeds[j].latestRoundData();

            DataInfo memory info = DataInfo({
                roundId: id,
                value: value,
                feed: s.priceFeeds[j]
            });
            infoFeeds[j] = info;
        }

        //ethPrice feed
        // int256 linkEth = infoFeeds[1].value.formatLinkEth();
        (int256 basePrice, int256 prevEth) = getBasePrice(infoFeeds[1]);

        return (infoFeeds, basePrice, prevEth); 
    }

    //-------------------

    function _getTwapEth() public view returns(int256) { //returns(int56[] memory ticks, uint160[] memory secs)
        address ethUsdcPool = 0xC31E54c7a869B9FcBEcc14363CF510d1c41fa443;
        address wethAddr = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
        address usdcAddr = 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8;
    
        (int24 tick,) = OracleLibrary.consult(ethUsdcPool, uint32(10));

        uint256 amountOut = OracleLibrary.getQuoteAtTick(
            tick, 1 * 1 ether, wethAddr, usdcAddr
        );
    
        return int256(amountOut * 10 ** 12); 

    }


    function getBasePrice(DataInfo memory ethFeedInfo_) public view returns(int256, int256) {
        int256 prevLinkEth = ethFeedInfo_.roundId.getPrevFeed(ethFeedInfo_.feed);
        int256 twapEth = _getTwapEth();
        int256 linkEth = ethFeedInfo_.value.formatLinkEth();

        return checkEthDiff(twapEth, linkEth, prevLinkEth * 10 ** 10) ? 
            (linkEth, prevLinkEth) : 
            (twapEth, prevLinkEth);
    }


    function checkEthDiff(
        int256 twap_, 
        int256 link_, 
        int256 prevLink_
    ) public pure returns(bool) 
    {
        int256 prevDiff = twap_ - prevLink_;
        int256 diff = twap_ - link_;
        int256 PERCENTAGE_DIFF = 5;

        int256 prevPerDiff = (abs(prevDiff) * 100) / twap_;
        int256 perDiff = (abs(diff) * 100) / twap_;

        return perDiff > PERCENTAGE_DIFF ? prevPerDiff > PERCENTAGE_DIFF : false;
    }


    function abs(int256 num_) public pure returns(int256) {
        return num_ >= 0 ? num_ : -num_;
    }




    //------------------

    function _setPrice(
        DataInfo memory feedInfo_, 
        int256 volIndex_,
        int256 prevEthPrice_
    ) private view returns(int256) 
    {
        if (address(feedInfo_.feed) != address(s.ethFeed)) {
            int256 currPrice = feedInfo_.value;
            int256 netDiff = currPrice - feedInfo_.roundId.getPrevFeed(feedInfo_.feed);
            return ( (netDiff * 100 * EIGHT_DEC) / currPrice ) * (volIndex_ / NINETN_DEC);
        } else {
            // int256 prevEthPrice = feedInfo_.roundId.getPrevFeed(feedInfo_.feed);
            int256 netDiff = feedInfo_.value - prevEthPrice_;
            return (netDiff * 100 * EIGHT_DEC) / prevEthPrice_;
        }
    }


    /*///////////////////////////////////////////////////////////////
                            Admin methods
    //////////////////////////////////////////////////////////////*/

    function changeVolatilityIndex(AggregatorV3Interface newFeed_) external {
        LibDiamond.enforceIsContractOwner();
        s.volatilityFeed = newFeed_;
    }

    function addFeed(AggregatorV3Interface newFeed_) external {
        LibDiamond.enforceIsContractOwner();

        int256 index = s.priceFeeds.indexOf(address(newFeed_));
        if (index != -1) revert AlreadyFeed(address(newFeed_));

        s.priceFeeds.push(newFeed_);
    }

    function removeFeed(AggregatorV3Interface toRemove_) external {
        LibDiamond.enforceIsContractOwner();

        int256 index = s.priceFeeds.indexOf(address(toRemove_));
        if (index == -1) revert NotFeed(address(toRemove_));

        LibCommon.remove(s.priceFeeds, toRemove_);
    }

    function getPriceFeeds() external view returns(address[] memory feeds) {
        uint256 length = s.priceFeeds.length;
        feeds = new address[](length);

        for (UC i=ZERO; i < uc(length); i = i + ONE) {
            uint256 j = i.unwrap();
            feeds[j] = address(s.priceFeeds[j]);
        }
    }

    /*///////////////////////////////////////////////////////////////
                            View methods
    //////////////////////////////////////////////////////////////*/

    function getVolatilityIndex() public view returns(int256) {
        (, int256 volatility,,,) = s.volatilityFeed.latestRoundData();
        return volatility;
    }


}




