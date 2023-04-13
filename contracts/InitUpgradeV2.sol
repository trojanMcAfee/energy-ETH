// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import './AppStorage.sol';
import '../libraries/LibDiamond.sol';
// import 'hardhat/console.sol';

import "forge-std/console.sol";

contract InitUpgradeV2 {

    AppStorage s;

    function init(
        address[] calldata feeds_,
        address[] memory nonRevFacets_
    ) external {

        s.wtiFeed = AggregatorV3Interface(feeds_[0]);
        s.volatilityFeed = AggregatorV3Interface(feeds_[1]);
        s.ethFeed = AggregatorV3Interface(feeds_[2]);
        s.goldFeed = AggregatorV3Interface(feeds_[3]);

        s.feeds.push(AggregatorV3Interface(feeds_[0]));
        s.feeds.push(AggregatorV3Interface(feeds_[2]));
        s.feeds.push(AggregatorV3Interface(feeds_[3]));

        address ozOracle = nonRevFacets_[0];
        bytes32 oracleID = keccak256(abi.encodePacked(ozOracle));

        s.idToOracle[oracleID] = ozOracle;
        bytes memory oracleDetails = abi.encode(ozOracle, oracleID);
        s.oraclesToIds.push(oracleDetails);

        LibDiamond.setNonRevenueFacets(nonRevFacets_); //test if anyone cann call setNonRevenueFacets
    
    }
}