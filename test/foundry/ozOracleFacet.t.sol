// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "forge-std/Test.sol";
import './Setup.sol';

import "forge-std/console.sol";


contract ozOracleFacetTest is Test, Setup {

    using stdStorage for StdStorage;
    
    function test_getEnergyPrice() public {
        uint256 price = OZL.getEnergyPrice();
        assertTrue(price > 0);
    }

    function test_getVolatilityIndex() public {
        int256 index = OZL.getVolatilityIndex();
        assertTrue(index > 0);
    }

    function test_changeVolatilityIndex() public {
        //Pre-condition
        address volAddr = _getVolAddress();
        assertTrue(volAddr == volIndex);

        //Action
        vm.prank(deployer);
        OZL.changeVolatilityIndex(AggregatorV3Interface(deadAddr));

        //Post-condition
        volAddr = _getVolAddress();
        assertTrue(volAddr == deadAddr);
    }

    function test_fail_changeVolatilityIndex_notOwner() public {
        //Pre-condition
        address volAddr = _getVolAddress();
        assertTrue(volAddr == volIndex);

        //Action
        vm.expectRevert(notOwner);
        OZL.changeVolatilityIndex(AggregatorV3Interface(deadAddr));   
    }

    function test_addFeed() public {
        //Pre-condition
        address[] memory feeds = OZL.getPriceFeeds();
        assertTrue(feeds.length == 3);

        //Action
        vm.prank(deployer);
        OZL.addFeed(AggregatorV3Interface(deadAddr));

        //Post-condition
        feeds = OZL.getPriceFeeds();
        assertTrue(feeds.length == 4);
    }

    //-------- Helpers

    function _getVolAddress() private view returns(address volAddr) {
        bytes32 volSlot = vm.load(address(OZL), bytes32(uint256(63)));
        volAddr = address(bytes20(volSlot << 96));
    }

  


   

}