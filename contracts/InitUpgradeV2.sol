// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import './AppStorage.sol';


contract InitUpgradeV2 {

    AppStorage s;

    function init(address[] calldata feeds_) external {

        s.wtiFeed = AggregatorV3Interface(feeds_[0]);
        s.volatilityFeed = AggregatorV3Interface(feeds_[1]);
        s.ethFeed = AggregatorV3Interface(feeds_[2]);
        s.goldFeed = AggregatorV3Interface(feeds_[3]);

    }


}