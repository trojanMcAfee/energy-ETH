// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";


struct AppStorage {

    AggregatorV3Interface wtiFeed;
    AggregatorV3Interface volatilityFeed;
    AggregatorV3Interface ethFeed;
    AggregatorV3Interface goldFeed;

    address tricrypto;
    address USDT;
    address executor;
    address yTriPool;
    address crvTricrypto;

    uint256 defaultSlippage;
    uint256 failedFees;
    uint256 feesVault;
}


struct DataInfo {
    uint80 roundId;
    int256 value;
}

struct Data {
    DataInfo volIndex;
    DataInfo wtiPrice;
    DataInfo ethPrice;
    DataInfo goldPrice;
}