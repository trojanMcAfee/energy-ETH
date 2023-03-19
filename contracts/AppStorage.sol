// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";


struct AppStorage {

    AggregatorV3Interface wtiFeed;
    AggregatorV3Interface volatilityFeed;
    AggregatorV3Interface ethFeed;
    AggregatorV3Interface goldFeed;

    int eETHprice;
}