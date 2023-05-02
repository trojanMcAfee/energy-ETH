// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import { UC, ONE, ZERO } from "unchecked-counter/UC.sol";
import '../AppStorage.sol';
import '../../libraries/LibHelpers.sol';
import '../../libraries/LibDiamond.sol';
import '../../libraries/LibCommon.sol';
import '../../Errors.sol';
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';
// import '@uniswap/v3-periphery/contracts/libraries/OracleLibrary.sol';
import '../../libraries/oracle/OracleLibrary.sol';
import '../../libraries/oracle/FullMath.sol';
import "@uniswap/v3-core/contracts/libraries/FixedPoint96.sol";
import '@rari-capital/solmate/src/utils/FixedPointMathLib.sol';

// import 'hardhat/console.sol';
import "forge-std/console.sol";


contract ozOracleFacet {

    AppStorage s;

    using LibHelpers for *;

    int256 private constant EIGHT_DEC = 1e8;


    //**** MAIN ******/

    function getEnergyPrice() external view returns(uint256) {

        ( 
            DataInfo[] memory infoFeeds, 
            int256 basePrice, 
            int256 prevEth 
        ) = _getDataFeeds();
      
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
        (int256 basePrice, int256 prevEth) = _getBasePrice(infoFeeds[1]);

        return (infoFeeds, basePrice, prevEth); 
    }

    //-------------------

    function _getBasePrice(DataInfo memory ethFeedInfo_) private view returns(int256, int256) {
        int256 prevLinkEth = ethFeedInfo_.roundId.getPrevFeed(ethFeedInfo_.feed);
        int256 twapEth = getTwapEth();
        int256 linkEth = ethFeedInfo_.value.formatLinkEth();

        return twapEth.checkEthDiff(linkEth, prevLinkEth * 1e10) ? 
            (linkEth, prevLinkEth) : 
            (twapEth, prevLinkEth);
    }


    function getTwapEth() public view returns(int256) { 
        (int24 tick,) = OracleLibrary.consult(s.uniPoolETHUSD, uint32(10));

        uint256 amountOut = OracleLibrary.getQuoteAtTick(
            tick, 1 ether, s.WETH, s.USDC
        );
    
        return int256(amountOut * 1e12); 
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
            return ( (netDiff * 100 * EIGHT_DEC) / currPrice ) * (volIndex_ / 1e19);
        } else {
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

    function changeUniPool(address newPool_) external {
        LibDiamond.enforceIsContractOwner();
        s.uniPoolETHUSD = newPool_;
    }

    /*///////////////////////////////////////////////////////////////
                            View methods
    //////////////////////////////////////////////////////////////*/

    function getVolatilityIndex() public view returns(int256) {
        (, int256 volatility,,,) = s.volatilityFeed.latestRoundData();
        return volatility;
    }


    function getPriceFeeds() external view returns(address[] memory feeds) {
        uint256 length = s.priceFeeds.length;
        feeds = new address[](length);

        for (UC i=ZERO; i < uc(length); i = i + ONE) {
            uint256 j = i.unwrap();
            feeds[j] = address(s.priceFeeds[j]);
        }
    }

    function getUniPool() external view returns(address) {
        return s.uniPoolETHUSD;
    }


}



