// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;



contract NewOracle {
    function getVolatilityIndex() public pure returns(int256){
        return int256(50);
    }
}