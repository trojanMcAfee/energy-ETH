// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import '../AppStorage.sol';


contract ozLoupeV2Facet {

    AppStorage s;


    function getFeesVault() external view returns(uint256) {
        return s.feesVault;
    }

}