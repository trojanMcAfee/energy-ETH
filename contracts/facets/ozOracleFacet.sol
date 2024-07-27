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
import '../../libraries/oracle/OracleLibrary.sol';
import '../../libraries/oracle/FullMath.sol';
import "@uniswap/v3-core/contracts/libraries/FixedPoint96.sol";
import '@rari-capital/solmate/src/utils/FixedPointMathLib.sol';

import { console } from "forge-std/console.sol";


/**
 * @title Where eETH gets created. 
 * @notice Contains the methods in charge of accounting and the price action 
 * distribution per asset that shapes how eETH will behave. 
 * 
 * It also has the main entry function to get eETH's price. 
 */
contract ozOracleFacet {

    AppStorage s;

    using LibHelpers for *;

    int256 private constant EIGHT_DEC = 1e8;


    /*///////////////////////////////////////////////////////////////
                            Entry method
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Gets the price in USD of Energy-ETH.
     * @dev It aggregates the net price differences of WTI and Gold in
     * function of basePrice's ratio and adds it to basePrice itself. 
     * @return price of eETH.
     */
    function getEnergyPrice() external view returns(uint256) {

        ( 
            DataInfo[] memory infoFeeds, 
            int256 basePrice, 
            int256 prevEth 
        ) = _getDataFeeds();
      
        int256 netDiff;

        uint256 length = infoFeeds.length;
        for (UC i=ZERO; i < uc(length); i = i + ONE) {
            DataInfo memory info = infoFeeds[i.unwrap()];

            netDiff += _setPrice(
                info, address(info.feed) == address(s.ethFeed) ? 
                        int256(0) : getVolatilityIndex(), 
                prevEth
            );
        }

        console.log('');
        console.log('--- in getEnergyPrice ---');
        console.log('basePrice: ', uint(basePrice));
        console.log('infoFeeds.length - 3: ', infoFeeds.length);
        console.log('XAU: ', uint(infoFeeds[2].value));
        console.log('old volatility index: ', uint(getVolatilityIndex()));
        console.log('GARCH last conditional vol: ', getVolatilityIndex2());
        console.log('');

        return uint256(basePrice + ( (netDiff * basePrice) / (100 * EIGHT_DEC) ));
    }


    /*///////////////////////////////////////////////////////////////
                        eETH calculation methods
    //////////////////////////////////////////////////////////////*/


    /**
     * @dev Gets base values to calculate eETH:
     * @return each of the feeds that compound eETH (Gold and WTI).
     * @return base price (ETHUSD) to which Gold and WTIY will be calculated into.
     * @return previous Chainlink price update of ETHUSD.
     */
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


    /**
     * @dev Calculates the basePrice of eETH, after cross-checking for a deviation
     * ration between Chailink and Uniswap TWAP Spot oracle's prices. 
     * @param ethFeedInfo_ contains the details of Chalinkink ETHUSD feed.
     * @return ETHUSD price to use (either TWAP or Chainlink).
     * @return the previous price reading for ETHUSD through Chainlink.
     */
    function _getBasePrice(DataInfo memory ethFeedInfo_) private view returns(int256, int256) {
        int256 prevLinkEth = ethFeedInfo_.roundId.getPrevFeed(ethFeedInfo_.feed);
        int256 linkEth = ethFeedInfo_.value.formatLinkEth();
        int256 twapEth = getTwapEth();

        return twapEth.checkEthDiff(linkEth, prevLinkEth * 1e10) ? 
            (linkEth, prevLinkEth) : 
            (getTwapEth(), prevLinkEth);
    }


    /**
     * @notice Sets the aggregated product of the combination of feed prices (WTI and Gold)
     * plus the volatility index.
     * @dev It amplifies the price difference of the prior and current price update by
     * multipling it by CL's volatility index.
     * @param feedInfo_ values of price feed to manipulate.
     * @param volIndex_ chainlink's volatility index to influce the price differences of each feed.
     * @param prevEthPrice_ previous update of ETHUSD.
     * @return influenced (by the volatility index) product from price feed updated
     */
    function _setPrice(
        DataInfo memory feedInfo_, 
        int256 volIndex_,
        int256 prevEthPrice_
    ) private view returns(int256) 
    {
        if (address(feedInfo_.feed) != address(s.ethFeed)) {
            int256 currPrice = feedInfo_.value;
            int256 netDiff = currPrice - feedInfo_.roundId.getPrevFeed(feedInfo_.feed);

            console.log('');
            console.log('--- in _setPrice ---');
            console.logInt(netDiff);
            console.log('netDiff ^^^');
            console.log('currPrice: ', uint(currPrice));
            console.log('volIndex_: ', uint(volIndex_));
            console.logInt(( (netDiff * 100 * EIGHT_DEC) / currPrice ) * (volIndex_ / 1e19));
            console.log('is ^^^');
            console.log('');

            return ( (netDiff * 100 * EIGHT_DEC) / currPrice ) * (volIndex_ / 1e19);
        } else {
            int256 netDiff = feedInfo_.value - prevEthPrice_;
            return (netDiff * 100 * EIGHT_DEC) / prevEthPrice_;
        }
    }



    /*///////////////////////////////////////////////////////////////
                            Admin methods
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Changes Chainlink's feed in charge of the volatility index.
     * @param newFeed_ new volatility index feed.
     */
    function changeVolatilityIndex(AggregatorV3Interface newFeed_) external {
        LibDiamond.enforceIsContractOwner();
        s.volatilityFeed = newFeed_;
    }

    /**
     * @dev Adds a new feed to be part of eETH's calculations.
     * @param newFeed_ represents a new asset fo eETH's price action.
     */
    function addFeed(AggregatorV3Interface newFeed_) external {
        LibDiamond.enforceIsContractOwner();

        int256 index = s.priceFeeds.indexOf(address(newFeed_));
        if (index != -1) revert AlreadyFeed(address(newFeed_));

        s.priceFeeds.push(newFeed_);
    }

    /**
     * @dev Removes a feed from eETH's calculations.
     * @param toRemove_ asset feed that will be removed.
     */
    function removeFeed(AggregatorV3Interface toRemove_) external {
        LibDiamond.enforceIsContractOwner();

        int256 index = s.priceFeeds.indexOf(address(toRemove_));
        if (index == -1) revert NotFeed(address(toRemove_));

        LibCommon.remove(s.priceFeeds, toRemove_);
    }

    /**
     * @dev Changes the Uniswap pool used as TWAP oracle.
     * @param newPool_ new Uniswap pool.
     */
    function changeUniPool(address newPool_) external {
        LibDiamond.enforceIsContractOwner();
        s.uniPoolETHUSD = newPool_;
    }

    /*///////////////////////////////////////////////////////////////
                        External view methods
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Gets Uniswap's TWAP Spot Oracle price.
     * @return ETHUSD from TWAP.
     */
    function getTwapEth() public view returns(int256) { 
        (int24 tick,) = OracleLibrary.consult(s.uniPoolETHUSD, uint32(10));

        uint256 amountOut = OracleLibrary.getQuoteAtTick(
            tick, 1 ether, s.WETH, s.USDC
        );
    
        return int256(amountOut * 1e12); 
    }

    /**
     * @dev Gets Chainlink's volatility index to be used to amplify the price
     * different of each asset feed (WTI and Gold).
     * @return volatility index.
     */
    function getVolatilityIndex() public view returns(int256) {
        (, int256 volatility,,,) = s.volatilityFeed.latestRoundData();
        return volatility;
    }

    function getVolatilityIndex2() public view returns(uint) {
        return s.garch.lastConditional;
    }

    /**
     * @dev Gets all the feeds use in eETH's calculations.
     * @return feeds - array of feeds addresses.
     */
    function getPriceFeeds() external view returns(address[] memory feeds) {
        uint256 length = s.priceFeeds.length;
        feeds = new address[](length);

        for (UC i=ZERO; i < uc(length); i = i + ONE) {
            uint256 j = i.unwrap();
            feeds[j] = address(s.priceFeeds[j]);
        }
    }

    /**
     * @dev Gets the ETHUSD 0.05% Uniswap pool. 
     * @return pool.
     */
    function getUniPool() external view returns(address) {
        return s.uniPoolETHUSD;
    }
}

