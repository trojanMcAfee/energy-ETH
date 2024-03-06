// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import "forge-std/Test.sol";
import './Setup.sol';


/**
 * @dev Tests that new view stats functions work properly. 
 */
contract ozLoupeV2FacetTest is Test, Setup {

    /**
     * @dev Tests that you can query the oracles that form part
     * of the Ozel system.
     */
    function test_getOracles() public {
        address[] memory oracles = OZL.getOracles();
        assertTrue(address(ozOracle) == oracles[0]);
    }

    /**
     * @dev Tests that you can query an oracle's ID by its address.
     */
    function test_getOracleIdByAddress() public {
        bytes32 oracleID = OZL.getOracleIdByAddress(address(ozOracle));
        bytes32 calcID = keccak256(abi.encodePacked(address(ozOracle)));
        assertTrue(oracleID == calcID);
    }

    /**
     * @dev Tests that you can query an oracle's address by its ID.
     */
    function test_getOracleAddressById() public {
        bytes32 id = keccak256(abi.encodePacked(address(ozOracle)));
        address oracle = OZL.getOracleAddressById(id);
        assertTrue(oracle == address(ozOracle));
    }
}