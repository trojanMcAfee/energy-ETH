// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import './AppStorage.sol';
import '../libraries/LibDiamond.sol';


/**
 * @title Initiates version 2 of OZL system.
 * @notice Sets the new storage variables needed for eETH to run
 */
contract InitUpgradeV2 {

    AppStorage s;

    /**
     * @dev Only function that initiates new storage within the diamond. 
     * @param feeds_ chainlink price feeds + volatility index. 
     * @param nonRevFacets_ facets/contracts that don't require a check for
     * admin revenue when calling the ozDiamond.
     * @param otherVars_ miscellaneous storage vars. 
     */
    function init(
        address[] calldata feeds_,
        address[] memory nonRevFacets_,
        address[] memory otherVars_,
        Garch[2] memory garch_
    ) external {

        s.wtiFeed = AggregatorV3Interface(feeds_[0]);
        s.volatilityFeed = AggregatorV3Interface(feeds_[1]);
        s.ethFeed = AggregatorV3Interface(feeds_[2]);
        s.goldFeed = AggregatorV3Interface(feeds_[3]);

        s.priceFeeds.push(AggregatorV3Interface(feeds_[0]));
        s.priceFeeds.push(AggregatorV3Interface(feeds_[2]));
        s.priceFeeds.push(AggregatorV3Interface(feeds_[3]));

        address ozOracle = nonRevFacets_[0];
        bytes32 oracleID = keccak256(abi.encodePacked(ozOracle));

        s.idToOracle[oracleID] = ozOracle;
        bytes memory oracleDetails = abi.encode(ozOracle, oracleID);
        s.oracles_ids.push(oracleDetails);

        s.uniPoolETHUSD = otherVars_[0];

        LibDiamond.setNonRevenueFacets(nonRevFacets_); 

        s.garchETH = garch_[0];
        s.garchXAU = garch_[1];
    }
}