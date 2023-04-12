// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import "forge-std/Test.sol";
import './Setup.sol';

import "forge-std/console.sol";



contract ozLoupeV2FacetTest is Test, Setup {


    function test_getOracles() public {
        address[] memory oracles = OZL.getOracles();
        assertTrue(address(ozOracle) == oracles[0]);
    }

    function test_getOracleIdByAddress() public {
        bytes32 oracleID = OZL.getOracleIdByAddress(address(ozOracle));
        bytes32 calcID = keccak256(abi.encodePacked(address(ozOracle)));
        assertTrue(oracleID == calcID);
    }

    function test_getOracleAddressById() public {
        bytes32 id = keccak256(abi.encodePacked(address(ozOracle)));
        address oracle = OZL.getOracleAddressById(id);
        assertTrue(oracle == address(ozOracle));
    }



}