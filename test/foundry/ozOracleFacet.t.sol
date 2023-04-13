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

    // function test_changeVolatilityIndex() public {
    //     //Pre-condition
    //     assertTrue(address(s.volatilityFeed) == volIndex);

    //     //Action
    //     vm.prank(deployer);
    //     OZL.changeVolatilityIndex(AggregatorV3Interface(deadAddr));

    //     //Post-condition
    //     assertTrue(address(s.volatilityFeed) == deadAddr);
    // }

    function test_getStorage() public {
        
        // uint256 slot = stdstore
        //     .target(address(OZL))
        //     .sig('AppStorage()')
        //     .depth(0)
        //     .find();

        // console.log('slot: ', slot);

        // assertTrue(false);

        //-----------
        address token = 0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9;

        bytes32 slot = vm.load(address(OZL), bytes32(uint256(16)), token);
        console.logBytes32(slot);
        console.log('slot ^^');


    }

}