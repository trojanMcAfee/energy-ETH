// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import "forge-std/Test.sol";
import './Setup.sol';


/**
 * @dev Tests that the new admin functions are working properly. 
 */
contract ozCutFacetV2Test is Test, Setup {

    /**
     * @dev Tests that the owner can successfully add a 
     * new oracle to the system.
     */
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

    /**
     * @dev Tests that the owner can successfully remove an 
     * oracle from the system.
     */
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

    /**
     * @dev Fails when a non-owner tries to add an oracle.
     */
    function test_addOracle_notOwner() public {
        //Pre-condition
        address[] memory oracles = OZL.getOracles();
        assertTrue(oracles.length == 1);

        //Action
        bytes32 deadID = keccak256(abi.encodePacked(deadAddr));
        vm.expectRevert(notOwner);
        OZL.addOracle(deadAddr, deadID);
    }

    /**
     * @dev Fails when a non-owner tries to remove an oracle.
     */
    function test_removeOracle_notOwner() public {
        //Pre-condition
        address[] memory oracles = OZL.getOracles();
        assertTrue(oracles.length == 1);

        //Action
        vm.expectRevert(notOwner);
        OZL.removeOracle(address(ozOracle));
    }
}