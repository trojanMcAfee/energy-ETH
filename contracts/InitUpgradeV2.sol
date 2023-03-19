// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import './AppStorage.sol';


contract InitUpgradeV2 {

    AppStorage s;

    struct InitVars {
        address[] feeds;
        int eETHprice;
    }

    function init(InitVars calldata vars_) external {

        s.wtiFeed = vars_.feeds[0];
        s.volatilityFeed = vars_.feeds[1];
        s.ethFeed = vars_.feeds[2];
        s.goldFeed = vars_.feeds[3];


    }


}