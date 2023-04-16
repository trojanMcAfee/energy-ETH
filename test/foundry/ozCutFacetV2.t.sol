// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import "forge-std/Test.sol";
import './Setup.sol';

import "forge-std/console.sol";


contract ozCutFacetV2Test is Test, Setup {


    function test_addOracle() public {
        //Pre-condition
        address[] memory oracles = OZL.getOracles();
        assertTrue(oracles.length == 1);

        //Action
        bytes32 deadID = keccak256(abi.encodePacked(deadAddr));
        vm.prank(deployer);
        OZL.addOracle(deadAddr, deadID);

        //Post-condition
        oracles = OZL.getOracles();
        assertTrue(oracles.length == 2);

        address oracleDead = OZL.getOracleAddressById(deadID);
        assertTrue(oracleDead == deadAddr);
    }

    function test_removeOracle() public {
        //Pre-condition
        address[] memory oracles = OZL.getOracles();
        assertTrue(oracles.length == 1);

        //Action
        vm.prank(deployer);
        OZL.removeOracle(address(ozOracle));

        //Post-condition
        oracles = OZL.getOracles();
        assertTrue(oracles.length == 0);
    }

    function test_addOracle_notOwner() public {
        //Pre-condition
        address[] memory oracles = OZL.getOracles();
        assertTrue(oracles.length == 1);

        //Action
        bytes32 deadID = keccak256(abi.encodePacked(deadAddr));
        vm.expectRevert(notOwner);
        OZL.addOracle(deadAddr, deadID);
    }

    function test_removeOracle_notOwner() public {
        //Pre-condition
        address[] memory oracles = OZL.getOracles();
        assertTrue(oracles.length == 1);

        //Action
        vm.expectRevert(notOwner);
        OZL.removeOracle(address(ozOracle));
    }



}